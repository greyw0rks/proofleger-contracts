# ProofLedger Vouchers

The `vouchers.clar` contract issues one-time use voucher codes tied to document proofs.

## Issue a Voucher

```clarity
(contract-call? .vouchers issue-voucher
  "GRADUATE2026"    ;; unique code
  0x<sha256-hash>   ;; linked document
  u1000000          ;; value (1 STX)
  u144)             ;; expires in 144 blocks (~1 day)
```

## Redeem a Voucher

```clarity
(contract-call? .vouchers redeem-voucher "GRADUATE2026")
;; Returns: (ok document-hash) on success
```

## Check Validity

```clarity
(contract-call? .vouchers is-valid-voucher "GRADUATE2026")
;; Returns: bool
```

## Use Cases
- Credential verification gating
- Event access with document proof
- One-time reward distribution