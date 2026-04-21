# ProofLedger Escrow

The `escrow.clar` contract holds STX until a depositor releases or refunds.

## Create Escrow

```clarity
(contract-call? .escrow create-escrow
  SP_BENEFICIARY
  u5000000        ;; 5 STX
  none)           ;; optional required proof hash
;; Returns: (ok escrow-id)
```

## Release Funds

```clarity
;; Depositor releases to beneficiary
(contract-call? .escrow release u1)
```

## Refund

```clarity
;; Depositor reclaims if conditions unmet
(contract-call? .escrow refund u1)
```

## Use Cases
- Freelance payment on work completion
- Credential verification fee escrow
- Document delivery milestone payments