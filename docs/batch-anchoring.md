# ProofLedger Batch Anchoring

The `proof-batch.clar` contract allows submitting 2 or 3 document hashes
in a single transaction, reducing fees for bulk issuers.

## Batch of 2

```clarity
(contract-call? .proof-batch submit-batch-2
  0x<hash-1> "MIT Diploma 2026"      "diploma"
  0x<hash-2> "MIT Transcript 2026"   "certificate"
  "Class of 2026 graduation batch")
;; Returns: (ok batch-id)
```

## Batch of 3

```clarity
(contract-call? .proof-batch submit-batch-3
  0x<hash-1> "Paper A" "research"
  0x<hash-2> "Paper B" "research"
  0x<hash-3> "Paper C" "research"
  "Q2 2026 research output")
```

## Read Back a Hash

```clarity
(contract-call? .proof-batch get-batch-hash u1 u0)
;; Returns: (some { hash, title, doc-type }) for batch-id=1, index=0
```

## When to Use

- Graduation ceremonies (many diplomas at once)
- Employer bulk credential issuance
- Research institution paper releases