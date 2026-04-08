# ProofLedger Security Checklist

## General Rules (All Contracts)

- [x] No hardcoded principals or private keys
- [x] All public functions have `asserts!` guards
- [x] Error codes documented
- [x] No unbounded loops or maps
- [x] No integer overflow (uint only)
- [x] `stacks-block-height` used (not `block-height`)

## Per-Contract

### proofleger3
- [x] Duplicate hash prevention (err u100)
- [x] Self-attest prevention (err u103)
- [x] One attestation per issuer per hash

### credentials
- [x] Only issuer can revoke (err u403)
- [x] No double-issuance

### achievements
- [x] Transfer always fails (err u500) — soulbound
- [x] One NFT per wallet per hash

### governance
- [x] One vote per wallet per proposal
- [x] Closed proposals reject votes

### registry
- [x] Only owner can verify issuers
- [x] No duplicate registrations

## Audit Status

Self-audited. Professional audit recommended before high-value use.