# ProofLedger Multi-Signature

The `multisig.clar` contract requires M-of-N approvals before a document is considered approved.

## Create a 2-of-3 Config

```clarity
(contract-call? .multisig create-config
  u2   ;; signatures required
  (list SP_SIGNER_1 SP_SIGNER_2 SP_SIGNER_3))
;; Returns: (ok config-id)
```

## Approve a Document

Each signer calls:
```clarity
(contract-call? .multisig approve u1 0x<sha256-hash>)
;; Returns: (ok false) until threshold met
;; Returns: (ok true) when threshold met
```

## Check Approval Status

```clarity
(contract-call? .multisig is-approved u1 0x<hash>)
;; Returns: bool
```

## Use Cases
- Board-approved document certification
- Joint credential issuance
- Multi-party contract notarization