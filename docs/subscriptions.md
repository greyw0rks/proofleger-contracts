# ProofLedger Subscriptions

The `subscriptions.clar` contract manages Pro feature access via STX payments.

## Subscribe

```clarity
(contract-call? .subscriptions subscribe "basic")      ;; 5 STX/month
(contract-call? .subscriptions subscribe "pro")        ;; 15 STX/month
(contract-call? .subscriptions subscribe "enterprise") ;; 50 STX/month
```

## Check Status

```clarity
(contract-call? .subscriptions is-subscribed tx-sender)  ;; bool
(contract-call? .subscriptions get-subscription tx-sender)
;; Returns: { tier, expires-at, started-at, total-paid }
```

## Renewing

Calling `subscribe` again before expiry extends the duration from the current expiry block.

## Tier Benefits

| Tier | Price | Features |
|---|---|---|
| Basic | 5 STX/month | Batch anchoring, export CSV |
| Pro | 15 STX/month | API access, analytics |
| Enterprise | 50 STX/month | Custom contracts, SLA |