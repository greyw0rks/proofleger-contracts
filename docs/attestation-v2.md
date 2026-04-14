# ProofLedger Attestation v2

Enhanced attestation with credibility weight and comments.

## Attest with Weight

```clarity
(contract-call? .attestation-v2 attest-with-weight
  0x<hash>
  "diploma"          ;; credential type
  u8                 ;; weight 1-10
  "Verified directly with institution")
```

## Get Credibility Score

The average weight of all attestors:

```clarity
(contract-call? .attestation-v2 get-credibility-score 0x<hash>)
;; Returns: uint (average weight, 1-10)
```

## Weight Guidelines

| Weight | Meaning |
|---|---|
| u10 | Direct institutional verification |
| u7-9 | Trusted secondary verification |
| u4-6 | Community attestation |
| u1-3 | Unverified claim |