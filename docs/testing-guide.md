# Testing Guide

## Install Clarinet

```bash
wget https://github.com/hirosystems/clarinet/releases/download/v2.4.0/clarinet-linux-x64-glibc.tar.gz
tar -xf clarinet-linux-x64-glibc.tar.gz && sudo mv clarinet /usr/local/bin
clarinet --version
```

## Run Tests

```bash
# All tests
clarinet test

# Specific test file
clarinet test tests/proofleger3_test.ts

# With coverage
clarinet test --coverage
```

## Test Files

| File | Contract |
|---|---|
| proofleger3_test.ts | Core anchoring |
| credentials_test.ts | Credentials |
| achievements_test.ts | Soulbound NFTs |
| endorsements_test.ts | Endorsements |
| profiles_test.ts | Profiles |
| revocations_test.ts | Revocations |
| reputation_test.ts | Reputation |
| collections_test.ts | Collections |
| badges_test.ts | Badges |
| governance_test.ts | Governance |
| subscriptions_test.ts | Subscriptions |
| messaging_test.ts | Messaging |
| timestamps_test.ts | Timestamps |
| oracle_test.ts | Oracle |

## CI

Tests run automatically via GitHub Actions on every push.