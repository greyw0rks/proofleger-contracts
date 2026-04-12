# ProofLedger Challenges

The `challenges.clar` contract lets anyone post a challenge requiring document proof.

## Create a Challenge

```clarity
(contract-call? .challenges create-challenge
  "Prove you have a CS degree"
  "diploma"         ;; required document type
  u10000000         ;; 10 STX reward
  u1008)            ;; ~1 week duration
;; Returns: (ok challenge-id)
```

## Submit Proof

```clarity
(contract-call? .challenges submit-proof
  u1               ;; challenge ID
  0x<sha256-hash>) ;; your document proof
```

## Use Cases
- Scholarship verification
- DAO contributor requirements
- Job application gating
- Hackathon eligibility