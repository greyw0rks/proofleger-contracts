# ProofLedger Proof of Work

The `proof-of-work.clar` contract lets contributors log work on-chain with document proofs.

## Log Work

```clarity
(contract-call? .proof-of-work log-work
  0x<sha256-hash>   ;; hash of work deliverable
  "Built ProofLedger mobile UI"
  "development"
  u40)              ;; hours worked
```

## Get Summary

```clarity
(contract-call? .proof-of-work get-work-summary tx-sender)
;; Returns: { count, total-hours }
```

## Use Cases
- Freelancer payment verification
- DAO contributor tracking
- Open source contribution proofs
- Consulting hour logs with deliverable hashes