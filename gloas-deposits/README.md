# Gloas Deposit Scenarios

Kurtosis configs that stress the Gloas (ePBS) builder/validator deposit path via
assertoor. Each `sN.yaml` launches a devnet and runs an assertoor playbook. All use
`gloas_fork_epoch: 1`.

- **s1, s2** are bulk-spam scenarios that reuse the upstream `builder-deposit-spam.yaml`
  playbook and the stock `ethpandaops/assertoor:master` image (no custom feature needed).
- **s3–s6** target a single repeated pubkey and need the `reuseIndex` flag, so they use
  the custom `jtraglia/assertoor:reuse-index` image and the playbooks under
  `playbooks/gloas-dev/deposits/sN.yaml` on the `reuse-index` branch of
  [jtraglia/assertoor](https://github.com/jtraglia/assertoor).

## Scenarios

| #  | What it does |
|----|--------------|
| s1 | Spams valid 0x03 builder deposits with unique pubkeys at ~200M gas/slot indefinitely, each onboarding a new builder so the ETH is recycled. |
| s2 | Spams valid 0x03 builder deposits with unique pubkeys before activation so a large backlog (~32k builders) onboards in the first slots after the fork. |
| s3 | Pre-fills the queue before the fork with 50k invalid 0x03 builder deposits for one pubkey (each a distinct invalid signature) followed by one valid 0x03 deposit for that pubkey. |
| s4 | Sends 5000 invalid 0x01 validator deposits plus one valid 0x03 builder deposit for the same pubkey, sized (5001) to land in a single payload. |
| s5 | Floods the queue with 50k invalid 0x01 validator deposits for one pubkey, then sends one valid 0x03 builder deposit for that same pubkey. |
| s6 | Sends 50k invalid 0x01 validator deposits for one pubkey, then a valid 0x01 validator deposit that onboards it, then a valid 0x03 builder deposit that should fold in as a top-up rather than create a builder. |

In the same-pubkey scenarios (s3–s6) each invalid deposit is burned as it processes;
the final valid deposit onboards the builder — except s6, where the pubkey is already a
validator, so the builder deposit should fold in as a balance top-up.

To test the "invalid signatures sprinkled in" variant of the bulk path, set `invalidSigPerc`
(0–100) in s1's config — the invalid deposits are burned and can't be batch-verified.

## Run

```
kurtosis clean -a && kurtosis run --enclave devnet github.com/ethpandaops/ethereum-package \
  --args-file gloas-deposits/s3.yaml --image-download always
```

Inspect queue / validator / builder state with `status.sh` in the repo root, e.g.
`./status.sh` or `./status.sh -d <slot>` for per-pubkey deposit counts.
