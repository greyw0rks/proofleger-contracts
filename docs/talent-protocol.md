# ProofLedger × Talent Protocol Integration

The `talent-verifier.clar` contract records verified Talent Protocol
builder scores on-chain, linking off-chain reputation to Stacks identity.

## Record a Builder Score

```clarity
;; Admin attests a Talent Protocol passport score
(contract-call? .talent-verifier attest
  SP_BUILDER_ADDRESS
  u82
  "passport-abc-123")
;; Returns: (ok u82)  ;; score recorded
```

## Check Verification Status

```clarity
(contract-call? .talent-verifier is-verified SP_ADDRESS)
;; Returns: bool

(contract-call? .talent-verifier get-score SP_ADDRESS)
;; Returns: (some u82)
```

## Use in Access Control

Other contracts can gate features behind Talent verification:

```clarity
(asserts!
  (contract-call? .talent-verifier is-verified tx-sender)
  (err u403))
```

## Score Threshold

The admin can set a minimum score required for `is-verified` to return true:

```clarity
(contract-call? .talent-verifier set-min-score u50)
;; Any score < 50 will return is-verified = false
```