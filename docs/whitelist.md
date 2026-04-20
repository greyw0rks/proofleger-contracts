# ProofLedger Issuer Whitelist

The `whitelist.clar` contract manages approved credential-issuing institutions.

## Institution: Request Approval

```clarity
(contract-call? .whitelist request-approval
  "University of Lagos"
  "university")
```

## Admin: Approve Issuer

```clarity
(contract-call? .whitelist approve-issuer
  SP_INSTITUTION_ADDRESS
  "University of Lagos"
  "university")
```

## Check Approval Status

```clarity
(contract-call? .whitelist is-approved SP_ADDRESS)
;; Returns: bool

(contract-call? .whitelist get-issuer-info SP_ADDRESS)
;; Returns: { name, category, approved-at, active }
```

## Categories

`university`, `professional-body`, `government`, `employer`, `ngo`, `bootcamp`, `other`