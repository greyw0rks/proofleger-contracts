# ProofLedger Challenges

The `challenges.clar` contract enables skill challenges with on-chain proof submission.

## Create a Challenge

```clarity
(contract-call? .challenges create-challenge
  "Build a ProofLedger integration"
  "development"
  u52560          ;; deadline (blocks from now, ~1 year)
  u5000000)       ;; 5 STX reward (or u0 for no reward)
;; Returns: (ok challenge-id)
```

## Submit a Proof

```clarity
(contract-call? .challenges submit-proof
  u1              ;; challenge ID
  0x<proof-hash>) ;; SHA-256 of submitted work
```

## Accept a Submission

```clarity
;; Creator only — distributes reward to winner
(contract-call? .challenges accept-submission u1 SP_WINNER)
```