# ProofLedger Issuer Registry

The `issuer-registry.clar` contract maintains an on-chain directory of
trusted credential issuers — universities, employers, DAOs, and governments.

## Self-Register

Any principal can register as an issuer:

```clarity
(contract-call? .issuer-registry self-register
  "MIT"
  "https://credentials.mit.edu"
  "university")
;; Returns: (ok true)
```

## Admin Verification

The registry admin marks an issuer as officially verified:

```clarity
(contract-call? .issuer-registry verify-issuer SP_MIT_ADDRESS)
```

## Check Issuer Status

```clarity
(contract-call? .issuer-registry is-verified-issuer SP_MIT_ADDRESS)
;; Returns: bool — true only if verified AND active
```

## Issuer Types

`university` · `employer` · `government` · `dao` · `other`

## Integration

When anchoring credentials, the anchor contract can call `record-issuance`
to keep per-issuer statistics updated on-chain.