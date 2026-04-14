# ProofLedger Credential Registry

The `credential-registry.clar` contract indexes all credentials by type for discovery.

## Register a Credential

```clarity
(contract-call? .credential-registry register-credential
  0x<sha256-hash>
  "diploma"           ;; credential type
  SP_SUBJECT_ADDRESS
  "BSc Computer Science 2026")
```

## Query by Type

```clarity
;; How many diplomas are registered?
(contract-call? .credential-registry get-type-count "diploma")

;; Get credential info by hash
(contract-call? .credential-registry get-credential 0x<hash>)
```

## Supported Types

`diploma`, `certificate`, `research`, `license`, `award`, `contribution`, `other`

## Total Registry Size

```clarity
(contract-call? .credential-registry get-total-credentials)
```