# Changelog

## [2.14.0] - 2026-04-28

### Added

**New Contracts — Governance & Bootstrap:**
- `whitelist.clar` — optional permission gate controlling who may anchor
- `proof-router.clar` — single entry-point routing anchors to sub-contracts
- `audit-trail.clar` — append-only log of admin and governance actions
- `genesis.clar` — protocol initialization with founding anchor and finalize lock

**Tests:**
- whitelist_test.ts — 4 test cases
- proof_router_test.ts — 4 test cases
- audit_trail_test.ts — 4 test cases
- genesis_test.ts — 4 test cases

**Docs:**
- whitelist.md — permission gate usage guide

## [2.13.0] - 2026-04-27
- reputation, delegation, verification-log, subscription-v2

## [2.12.0] - 2026-04-26
- document-registry, credential-schema, proof-batch, issuer-registry

## [1.0.0] - 2026-03-08
- Initial mainnet deployment