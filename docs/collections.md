# ProofLedger Collections

The `collections.clar` contract lets wallets group related documents.

## Create a Collection

```clarity
(contract-call? .collections create-collection
  "Academic Credentials 2026"
  "All university degrees and certifications"
  true)   ;; public
;; Returns: (ok collection-id)
```

## Add a Document

```clarity
(contract-call? .collections add-doc
  u1          ;; collection ID
  0x<hash>)   ;; document hash
;; Returns: (ok index)
```

## Read Collection

```clarity
(contract-call? .collections get-collection u1)
;; Returns: { owner, name, doc-count, public }

(contract-call? .collections get-doc-at u1 u0)
;; Returns: { hash, added-at }
```

## Use Cases
- Aggregate all credentials from one institution
- Curate a professional portfolio
- Group documents for a specific job application