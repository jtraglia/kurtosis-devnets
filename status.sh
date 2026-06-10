#!/usr/bin/env bash
# Print beacon-state status for a Kurtosis devnet: slot/epoch, validators
# (with credential-type breakdown), builders, and all the pending queues.
# Resolves the beacon endpoint itself.
#
# Usage:
#   ./status.sh [STATE_ID]            # one-shot, pretty JSON (default: head)
#   ./status.sh finalized             # any state_id: head / finalized / <slot> / <root>
#   ./status.sh -w [-i SECONDS]       # watch, compact one-line summary (default 12s)
#   ./status.sh -d [STATE_ID]         # pending_deposits per-pubkey dupes (count > 1)
#   ./status.sh -e ENCLAVE <state>    # different enclave (default: devnet)
#
# Env overrides:
#   ENCLAVE      enclave name (default: devnet)
#   CL_SERVICE   CL service name (default: auto-detected first cl-* container)
#   BEACON       beacon REST base URL (skips resolution if set)
set -euo pipefail

ENCLAVE="${ENCLAVE:-devnet}"
STATE_ID="head"
WATCH=0
INTERVAL=12
MODE="status"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -w|--watch) WATCH=1; shift ;;
    -i|--interval) INTERVAL="$2"; shift 2 ;;
    -e|--enclave) ENCLAVE="$2"; shift 2 ;;
    -d|--dupes) MODE="dupes"; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    -*) echo "unknown flag: $1" >&2; exit 2 ;;
    *) STATE_ID="$1"; shift ;;
  esac
done

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

resolve_beacon() {
  [[ -n "${BEACON:-}" ]] && { echo "${BEACON%/}"; return; }

  local svc="${CL_SERVICE:-}"
  if [[ -z "$svc" ]]; then
    svc=$(docker ps --format '{{.Names}}' | grep -E '^cl-[0-9]+-' | head -1 | sed 's/--.*//')
    [[ -z "$svc" ]] && { echo "could not find a running cl-* service (is enclave '$ENCLAVE' up?)" >&2; exit 1; }
  fi

  local url
  url=$(kurtosis port print "$ENCLAVE" "$svc" http 2>/dev/null) \
    || { echo "kurtosis port print failed for $ENCLAVE/$svc http" >&2; exit 1; }
  echo "${url%/}"
}

# SLOTS_PER_EPOCH from the chain spec (fallback 32) so epoch math isn't hardcoded.
slots_per_epoch() {
  local beacon="$1" spe
  spe=$(curl -s --max-time 15 "$beacon/eth/v1/config/spec" | jq -r '.data.SLOTS_PER_EPOCH // empty' 2>/dev/null)
  [[ "$spe" =~ ^[0-9]+$ ]] && echo "$spe" || echo 32
}

# Fetch the full state once and reduce it to a status object.
status() {
  local beacon="$1" spe="$2"
  curl -s --max-time 180 -H 'Accept: application/json' \
    "$beacon/eth/v2/debug/beacon/states/$STATE_ID" \
  | jq --argjson spe "$spe" '
      .data as $d
      | ($d.validators // []) as $vals
      | ($d.builders // []) as $blds
      | ($d.slot | tonumber) as $slot
      | ($slot / $spe | floor) as $epoch
      | {
          slot: $slot,
          epoch: $epoch,
          finalized_epoch: ($d.finalized_checkpoint.epoch | tonumber),
          justified_epoch: ($d.current_justified_checkpoint.epoch | tonumber),
          validators: {
            total: ($vals | length),
            active: ([$vals[]
                      | select((.activation_epoch | tonumber) <= $epoch
                               and (.exit_epoch | tonumber) > $epoch)] | length),
            by_credentials: (reduce $vals[] as $v ({};
                              .[$v.withdrawal_credentials[0:4]] += 1))
          },
          builders: {
            count: ($blds | length),
            total_balance_eth: (([$blds[].balance | tonumber] | add // 0) / 1000000000)
          },
          queues: {
            pending_deposits: (($d.pending_deposits // []) | length),
            pending_partial_withdrawals: (($d.pending_partial_withdrawals // []) | length),
            pending_consolidations: (($d.pending_consolidations // []) | length),
            builder_pending_payments: (($d.builder_pending_payments // []) | length),
            builder_pending_withdrawals: (($d.builder_pending_withdrawals // []) | length)
          },
          deposits: {
            balance_to_consume: $d.deposit_balance_to_consume,
            eth1_deposit_index: $d.eth1_deposit_index,
            requests_start_index: $d.deposit_requests_start_index
          }
        }'
}

# Group pending_deposits by pubkey, keep only pubkeys with more than one entry.
dupes() {
  local beacon="$1"
  curl -s --max-time 180 -H 'Accept: application/json' \
    "$beacon/eth/v2/debug/beacon/states/$STATE_ID" \
  | jq '
      (.data.pending_deposits // []) as $pd
      | ([$pd[] | {pubkey, withdrawal_credentials, signature}]
         | group_by(.pubkey)
         | map(select(length > 1) | {
             pubkey: .[0].pubkey,
             count: length,
             distinct_credentials: ([.[].withdrawal_credentials] | unique | length),
             distinct_signatures: ([.[].signature] | unique | length)
           })
         | sort_by(-.count)) as $dupes
      | {
          pending_deposits_total: ($pd | length),
          unique_pubkeys: ([$pd[].pubkey] | unique | length),
          pubkeys_with_multiple: ($dupes | length),
          duplicates: $dupes
        }'
}

BEACON_URL="$(resolve_beacon)"
SPE="$(slots_per_epoch "$BEACON_URL")"
echo "beacon:  $BEACON_URL  (slots/epoch: $SPE)" >&2
echo "state:   $STATE_ID" >&2

status_compact='"slot=\(.slot) ep=\(.epoch) fin=\(.finalized_epoch) "
        + "val=\(.validators.total)(a=\(.validators.active)) "
        + "builders=\(.builders.count) "
        + "pd=\(.queues.pending_deposits) "
        + "ppw=\(.queues.pending_partial_withdrawals) "
        + "pc=\(.queues.pending_consolidations)"'

dupes_compact='"pd=\(.pending_deposits_total) unique=\(.unique_pubkeys) "
        + "multi=\(.pubkeys_with_multiple) top=\(.duplicates[0].count // 0)"'

run() { if [[ "$MODE" == "dupes" ]]; then dupes "$BEACON_URL"; else status "$BEACON_URL" "$SPE"; fi; }

if [[ "$WATCH" -eq 1 ]]; then
  echo "watching every ${INTERVAL}s (Ctrl-C to stop)" >&2
  compact="$status_compact"; [[ "$MODE" == "dupes" ]] && compact="$dupes_compact"
  while true; do
    printf '%s  ' "$(date +%H:%M:%S)"
    run | jq -r "$compact" || echo "(query failed)"
    sleep "$INTERVAL"
  done
else
  run
fi
