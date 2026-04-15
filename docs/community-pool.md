# ProofLedger Community Pool

The `community-pool.clar` contract manages community funding for protocol development.

## Contribute

```clarity
(contract-call? .community-pool contribute u1000000)
;; Contribute 1 STX to the community pool
```

## Check Pool Balance

```clarity
(contract-call? .community-pool get-pool-balance)
(contract-call? .community-pool get-total-contributors)
```

## Your Contribution History

```clarity
(contract-call? .community-pool get-contribution tx-sender)
;; Returns: { total, count, first-at, last-at }
```

## Grants

The contract owner can disburse grants to contributors and builders:
```clarity
;; Owner only
(contract-call? .community-pool grant
  SP_RECIPIENT
  u5000000
  "ProofLedger SDK development Q2 2026")
```