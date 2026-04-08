# ProofLedger Collections

## Create a Collection

```clarity
(contract-call? .collections create-collection
  "Research Papers 2026"
  "My published research")
```

## Add Documents

```clarity
(contract-call? .collections add-to-collection
  "Research Papers 2026"
  0x<sha256-hash>)
```

## Read a Collection

```clarity
(contract-call? .collections get-collection tx-sender "Research Papers 2026")
;; Returns: { created-at, count, description }

(contract-call? .collections get-item tx-sender "Research Papers 2026" u0)
;; Returns first document hash in collection
```

## Use Cases
- Academic portfolios
- Professional credential bundles
- Art collections
- Project documentation sets