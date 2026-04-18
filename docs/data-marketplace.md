# ProofLedger Data Marketplace

The `data-marketplace.clar` contract enables monetization of verified datasets.

## List a Dataset

```clarity
(contract-call? .data-marketplace create-listing
  0x<dataset-hash>
  "Stacks On-Chain Analytics 2026"
  "Complete transaction analytics for Q1 2026"
  u5000000)   ;; 5 STX price
;; Returns: (ok listing-id)
```

## Purchase Access

```clarity
(contract-call? .data-marketplace purchase-access u1)
```

## Verify Access

```clarity
(contract-call? .data-marketplace has-access u1 SP_BUYER_ADDRESS)
;; Returns: bool
```

## Use Cases
- Research dataset licensing
- Market data subscriptions
- AI training data monetization
- Analytics report sales