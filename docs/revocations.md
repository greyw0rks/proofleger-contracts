# ProofLedger Revocations

The `revocations.clar` contract allows credential issuers to revoke previously anchored documents.

## Revoke a Credential

```clarity
(contract-call? .revocations revoke
  0x<document-hash>
  "Credential expired — holder left institution"
  (some SP_ORIGINAL_HOLDER))
```

## Check Revocation Status

```clarity
(contract-call? .revocations is-revoked 0x<hash>)
;; Returns: bool

(contract-call? .revocations get-revocation 0x<hash>)
;; Returns: { revoker, reason, revoked-at, original-owner }
```

## Challenge a Revocation

If a revocation is incorrect, the holder can challenge it on-chain:

```clarity
(contract-call? .revocations challenge-revocation
  0x<hash>
  "This credential is valid — revocation is in error")
```

## Integration

ProofLedger Verifier checks `revocations.is-revoked` on every verification call.
Revoked credentials show a red REVOKED badge instead of the green VERIFIED badge.