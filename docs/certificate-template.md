# ProofLedger Certificate Templates

The `certificate-template.clar` contract enables batch credential issuance via reusable templates.

## Create a Template

```clarity
(contract-call? .certificate-template create-template
  "Graduation Class 2026"
  "diploma"
  "Annual graduation certificate for CS graduates")
;; Returns: (ok template-id)
```

## Issue from Template

```clarity
;; Issue to each graduate
(contract-call? .certificate-template issue-from-template
  u1                   ;; template ID
  SP_STUDENT_ADDRESS
  0x<student-hash>)
```

## Read Template Stats

```clarity
(contract-call? .certificate-template get-template u1)
;; Returns: { creator, name, cert-type, issue-count, active }
```

## Advantages over Single Issuance
- Consistent metadata across all certificates in a batch
- Track total issuance count per template
- One recipient can only receive one certificate per template