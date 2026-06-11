# Gloas Deposit Scenarios

## Scenarios

| #  | Timing     | Description |
|----|------------|-------------|
| s1 | Post-Gloas | Continuously submits ~8,000 valid builder deposits with unique pubkeys. |
| s2 | Pre-Gloas  | Submits 262,144 valid builder deposits with unique pubkeys before the upgrade. All of these are processed/onboarded at the fork. |
| s3 | Pre-Gloas  | Submits 50,000 invalid builder deposits for a single pubkey, each with a distinct invalid signature, then one valid builder deposit for that pubkey. |
| s4 | Post-Gloas | In a single payload, submits 5,000 invalid validator deposits and one valid builder deposit for a single pubkey. |
| s5 | Post-Gloas | Submits 50,000 invalid validator deposits for a single pubkey, then one valid builder deposit for that pubkey. |
| s6 | Post-Gloas | Submits 50,000 invalid validator deposits for a single pubkey, then one valid validator deposit for that pubkey, then one valid builder deposit for that pubkey. |
| s7 | Pre-Gloas  | Submits 50,000 invalid validator deposits for a single pubkey, then one valid builder deposit for that pubkey. |
| s8 | Post-Gloas | Submits 50,000 invalid validator deposits for a single pubkey, then one invalid builder deposit for that pubkey. |
| s9 | Post-Gloas | Submits 50,000 invalid validator deposits for a single pubkey, then one invalid builder deposit for that pubkey every slot. |
