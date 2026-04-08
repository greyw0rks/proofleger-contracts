# ProofLedger Issuer Registry

## Register as an Issuer

```clarity
(contract-call? .registry register-issuer
  "MIT OpenCourseWare"
  "https://ocw.mit.edu")
```

## Check Verification Status

```clarity
(contract-call? .registry is-verified-issuer SP_ADDRESS)
;; Returns: bool
```

## Verification Process

1. Call `register-issuer` with your institution name and URL
2. The ProofLedger contract owner reviews the registration
3. Upon approval, `verify-issuer` is called by the owner
4. Your address is now marked as a verified issuer

## Why Get Verified?

Credentials issued by verified issuers receive a trust boost in the ProofLedger reputation system and display a verification badge on the UI.