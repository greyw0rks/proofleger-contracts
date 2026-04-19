# ProofLedger Vouchers

The `vouchers.clar` contract enables single-use credential vouchers backed by document proofs.

## Issue a Voucher

```clarity
(contract-call? .vouchers issue-voucher
  0x<random-unique-code>    ;; 32-byte unique voucher code
  0x<proof-hash>            ;; backing document hash
  "diploma")                ;; voucher type
```

## Redeem a Voucher

```clarity
(contract-call? .vouchers redeem-voucher 0x<voucher-code>)
```

## Check Status

```clarity
(contract-call? .vouchers get-voucher 0x<code>)
(contract-call? .vouchers is-redeemed 0x<code>)
```

## Use Cases
- Conference admission tokens
- One-time credential verification codes
- Referral or invitation codes backed by credentials