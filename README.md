# Kurtosis Devnets

## Usage

0. Clone the repository.

```
git clone git@github.com:jtraglia/kurtosis-devnets.git
cd kurtosis-devnets
```

1. If testing local changes, serve the assertoor playbooks.

```
python3 -m http.server 8765
```

2. Launch the devnet.

```
kurtosis enclave rm -f devnet
kurtosis run --enclave devnet github.com/ethpandaops/ethereum-package --args-file <path-to-kurtosis-config>
```
