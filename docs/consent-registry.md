# ProofLedger Consent Registry

The `consent-registry.clar` contract manages data processing consent on-chain.

## Grant Consent

```clarity
(contract-call? .consent-registry grant-consent
  SP_DATA_PROCESSOR
  "marketing-emails"
  (some u52560)   ;; expires in ~1 year (optional)
  none)           ;; optional proof hash
```

## Revoke Consent

```clarity
(contract-call? .consent-registry revoke-consent
  SP_DATA_PROCESSOR
  "marketing-emails")
```

## Check Valid Consent

```clarity
(contract-call? .consent-registry has-valid-consent
  SP_SUBJECT
  SP_PROCESSOR
  "marketing-emails")
;; Returns: false if revoked or expired
```

## GDPR Alignment
- Right to consent: `grant-consent`
- Right to withdraw: `revoke-consent`
- Right to verify: `has-valid-consent`
- All records are permanent and auditable