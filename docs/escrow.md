# ProofLedger Escrow

The `escrow.clar` contract locks STX until a document is verified on-chain.

## Create an Escrow

```clarity
(contract-call? .escrow create-escrow
  SP_RECIPIENT_ADDRESS
  0x<required-document-hash>
  u1000000)   ;; 1 STX
;; Returns: (ok escrow-id)
```

## Release Funds

The recipient calls this after providing proof:

```clarity
(contract-call? .escrow release-escrow u1)
```

## Use Cases
- Pay for credential verification
- Freelance payment on delivery proof
- Grant disbursement on milestone proof
- Insurance claim on document submission