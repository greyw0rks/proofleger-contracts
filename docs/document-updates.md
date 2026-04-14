# ProofLedger Document Updates

The `document-updates.clar` contract tracks when documents are superseded.

## Supersede a Document

```clarity
(contract-call? .document-updates supersede
  0x<old-hash>
  0x<new-hash>
  "Corrected calculation error in section 4")
```

## Check if Superseded

```clarity
(contract-call? .document-updates is-superseded 0x<hash>)
;; Returns: bool

(contract-call? .document-updates get-update 0x<old-hash>)
;; Returns: { new-hash, updater, updated-at, reason }
```

## Use Cases
- Academic paper corrections
- Contract amendments
- Policy updates with audit trail
- Software version documentation