# Changelog

## [2.12.0] - 2026-04-26

### Added

**New Contracts — Registry & Batch Layer:**
- `document-registry.clar` — canonical on-chain index of anchored documents with revoke/update
- `credential-schema.clar` — reusable credential templates published by issuers
- `proof-batch.clar` — anchor 2 or 3 documents in a single transaction
- `issuer-registry.clar` — verified issuer directory with admin verification flow

**Tests:**
- document_registry_test.ts — 4 test cases
- credential_schema_test.ts — 4 test cases
- proof_batch_test.ts — 4 test cases
- issuer_registry_test.ts — 4 test cases

**Docs:**
- issuer-registry.md — issuer onboarding guide
- batch-anchoring.md — bulk submission guide

## [2.11.0] - 2026-04-25
- timelock, oracle, fee-registry, proof-nft

## [2.10.0] - 2026-04-24
- slashing, rewards distributor, challenge-response, credential expiry

## [2.9.0] - 2026-04-23
- multisig, access-control, dispatcher, snapshots, attestation-v2

## [1.0.0] - 2026-03-08
- Initial mainnet deployment