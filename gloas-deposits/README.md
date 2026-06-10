# Gloas Deposit Scenarios

## Scenarios

| #  | What it does |
|----|--------------|
| s1 | Spams valid 0x03 builder deposits with unique pubkeys at ~200M gas/slot indefinitely, each onboarding a new builder so the ETH is recycled. |
| s2 | Spams valid 0x03 builder deposits with unique pubkeys before activation so a large backlog (~32k builders) onboards in the first slots after the fork. |
| s3 | Pre-fills the queue before the fork with 50k invalid 0x03 builder deposits for one pubkey (each a distinct invalid signature) followed by one valid 0x03 deposit for that pubkey. |
| s4 | Sends 5000 invalid 0x01 validator deposits plus one valid 0x03 builder deposit for the same pubkey, sized (5001) to land in a single payload. |
| s5 | Floods the queue with 50k invalid 0x01 validator deposits for one pubkey, then sends one valid 0x03 builder deposit for that same pubkey. |
| s6 | Sends 50k invalid 0x01 validator deposits for one pubkey, then a valid 0x01 validator deposit that onboards it, then a valid 0x03 builder deposit that should fold in as a top-up rather than create a builder. |
