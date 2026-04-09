# ProofLedger Certifier

The `certifier.clar` contract enables institutions to certify documents in batches.

## Create a Batch

```clarity
(contract-call? .certifier create-batch "Graduation Class 2026")
;; Returns: (ok u1) — batch ID
```

## Certify Documents

```clarity
(contract-call? .certifier certify
  0x<sha256-hash>
  u1               ;; batch ID
  "diploma")       ;; certificate type
```

## Check Certification

```clarity
(contract-call? .certifier is-certified SP_INSTITUTION 0x<hash>)
;; Returns: bool
```

## Use Cases

- Universities certifying graduating class
- Companies certifying employee training
- DAOs certifying contributor work