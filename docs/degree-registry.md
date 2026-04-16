# ProofLedger Degree Registry

The `degree-registry.clar` contract lets institutions issue verifiable degrees on-chain.

## Issue a Degree

```clarity
(contract-call? .degree-registry issue-degree
  0x<sha256-of-degree-document>
  SP_STUDENT_ADDRESS
  "Bachelor of Science"
  "Computer Science")
```

## Verify a Degree

```clarity
(contract-call? .degree-registry get-degree 0x<hash>)
;; Returns: { institution, student, degree-type, field, issued-at }
```

## Institution Stats

```clarity
(contract-call? .degree-registry get-institution-count SP_INSTITUTION)
(contract-call? .degree-registry get-total-degrees)
```

## Use Cases
- University degree verification
- Professional certification bodies
- Bootcamp completion certificates