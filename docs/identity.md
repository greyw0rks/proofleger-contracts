# ProofLedger Self-Sovereign Identity

The `identity.clar` contract creates wallet-native identity profiles with credential claims.

## Register Identity

```clarity
(contract-call? .identity register-identity
  "greyw0rks"
  "Web3 founder building on Stacks and Celo"
  0x<identity-document-hash>)
```

## Add a Claim

Link credentials to your identity:

```clarity
(contract-call? .identity add-claim
  "education"
  0x<degree-document-hash>)

(contract-call? .identity add-claim
  "employment"
  0x<work-contract-hash>)
```

## Read Identity

```clarity
(contract-call? .identity has-identity SP_ADDRESS)  ;; bool
(contract-call? .identity get-identity SP_ADDRESS)  ;; full profile
(contract-call? .identity get-claim SP_ADDRESS "education")
```

## Claim Types

`education`, `employment`, `certification`, `publication`, `identity`, `other`