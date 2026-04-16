# ProofLedger Work History

The `work-history.clar` contract lets employees and employers record verified employment history.

## Employee: Add Employment Record

```clarity
(contract-call? .work-history add-employment
  SP_EMPLOYER_ADDRESS
  "Senior Blockchain Developer"
  0x<employment-contract-hash>)
;; Returns: (ok record-index)
```

## Employer: Verify the Record

```clarity
(contract-call? .work-history verify-employment SP_EMPLOYEE u0)
```

## End Employment

```clarity
(contract-call? .work-history end-employment u0)
```

## Read History

```clarity
(contract-call? .work-history get-employment SP_EMPLOYEE u0)
(contract-call? .work-history get-employment-count SP_EMPLOYEE)
```