# Gloas Deposit Scenarios

## Scenarios

| #  | Gloas | Description |
|----|-------|-------------|
| s1 | Post  | Continuously submits ~8,000 valid builder deposits with unique pubkeys. |
| s2 | Pre   | Submits 262,144 valid builder deposits with unique pubkeys before the upgrade. All of these are processed/onboarded at the fork. |
| s3 | Pre   | Submits 50,000 invalid builder deposits for a single pubkey, each with a distinct invalid signature, then one valid builder deposit for that pubkey. |
| s4 | Post  | In a single payload, submits 5,000 invalid validator deposits and one valid builder deposit for a single pubkey. |
| s5 | Pre   | Submits 50,000 invalid validator deposits for a single pubkey, then one valid builder deposit for that pubkey. |
| s6 | Post  | Submits 50,000 invalid validator deposits for a single pubkey, then one valid builder deposit for that pubkey. |
| s7 | Post  | Submits 50,000 invalid validator deposits for a single pubkey, then one valid validator deposit for that pubkey, then one valid builder deposit for that pubkey. |
| s8 | Post  | Submits 50,000 invalid validator deposits for a single pubkey, then one invalid builder deposit for that pubkey. |
| s9 | Post  | Submits 50,000 invalid validator deposits for a single pubkey, then one invalid builder deposit for that pubkey every slot. |
