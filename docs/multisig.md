# ProofLedger Multi-Signature Wallets

The `multisig.clar` contract enables m-of-n multi-signature approval for critical actions.

## Create a 2-of-3 Wallet

```clarity
(contract-call? .multisig create-multisig
  (list SP_OWNER_1 SP_OWNER_2 SP_OWNER_3)
  u2)   ;; 2 approvals required
;; Returns: (ok wallet-id)
```

## Propose an Action

```clarity
(contract-call? .multisig propose
  u1
  "Deploy proofleger-v4 contract upgrade")
;; Returns: (ok proposal-id)
```

## Approve a Proposal

```clarity
(contract-call? .multisig approve u1 u1)
;; Each owner calls this separately
```

## Check Approval Status

```clarity
(contract-call? .multisig is-approved u1 u1)
;; Returns: true when approval-count >= threshold
```

## Use Cases
- Protocol upgrade approvals
- Treasury disbursements
- Credential issuer onboarding decisions