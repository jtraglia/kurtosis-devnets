# Kurtosis Devnets

## Usage

1. Clone the repository.

```
git clone git@github.com:jtraglia/kurtosis-devnets.git
cd kurtosis-devnets
```

2. Launch the devnet.

```
kurtosis clean -a && kurtosis run --enclave devnet github.com/ethpandaops/ethereum-package --args-file <path-to-kurtosis-config> --image-download always
```
