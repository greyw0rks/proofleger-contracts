# ProofLedger Expiring Credentials

The `expiring-credentials.clar` contract issues credentials with on-chain expiry dates.

## Issue with Expiry

```clarity
(contract-call? .expiring-credentials issue-expiring
  0x<sha256-hash>
  SP_SUBJECT_ADDRESS
  "professional-license"
  u52560)    ;; ~1 year in blocks (52560 blocks ≈ 365 days)
```

## Check Validity

```clarity
(contract-call? .expiring-credentials is-valid 0x<hash>)
;; Returns false after expiry or if revoked
```

## Revoke Early

Only the original issuer can revoke:
```clarity
(contract-call? .expiring-credentials revoke 0x<hash>)
```

## Use Cases
- Professional licenses (annual renewal)
- Access tokens (short-term)
- Temporary credentials
- Trial memberships