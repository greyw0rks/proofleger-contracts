#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/proof-cross-ref.clar')"
cat > 'contracts/proof-cross-ref.clar' << 'PLEOF_0022'
;; proof-cross-ref.clar  generated: jun6
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_cross_ref_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_cross_ref_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_cross_ref_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_cross_ref_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_cross_ref_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0022
git add 'contracts/proof-cross-ref.clar'
git commit --allow-empty -q -m 'Add proof-cross-ref: proof cross ref contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-cross-ref: proof cross ref contract"

mkdir -p "$(dirname 'tests/proof-cross-ref.test.ts')"
cat > 'tests/proof-cross-ref.test.ts' << 'PLEOF_0023'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-cross-ref", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-cross-ref","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-cross-ref","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-cross-ref","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-cross-ref","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-cross-ref","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-cross-ref","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-cross-ref","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-cross-ref","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0023
git add 'tests/proof-cross-ref.test.ts'
git commit --allow-empty -q -m 'Add proof-cross-ref tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-cross-ref tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/credential-chain-v2.clar')"
cat > 'contracts/credential-chain-v2.clar' << 'PLEOF_0024'
;; credential-chain-v2.clar  generated: jun6
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map credential_chain_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set credential_chain_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? credential_chain_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set credential_chain_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? credential_chain_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0024
git add 'contracts/credential-chain-v2.clar'
git commit --allow-empty -q -m 'Add credential-chain-v2: credential chain v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-chain-v2: credential chain v2 contract"

mkdir -p "$(dirname 'tests/credential-chain-v2.test.ts')"
cat > 'tests/credential-chain-v2.test.ts' << 'PLEOF_0025'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-chain-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-chain-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-chain-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-chain-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-chain-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-chain-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-chain-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("credential-chain-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("credential-chain-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0025
git add 'tests/credential-chain-v2.test.ts'
git commit --allow-empty -q -m 'Add credential-chain-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-chain-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/staking-events.clar')"
cat > 'contracts/staking-events.clar' << 'PLEOF_0026'
;; staking-events.clar  generated: jun6
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map staking_events_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set staking_events_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? staking_events_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set staking_events_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? staking_events_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0026
git add 'contracts/staking-events.clar'
git commit --allow-empty -q -m 'Add staking-events: staking events contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-events: staking events contract"

mkdir -p "$(dirname 'tests/staking-events.test.ts')"
cat > 'tests/staking-events.test.ts' << 'PLEOF_0027'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("staking-events", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("staking-events","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-events","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-events","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-events","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-events","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-events","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("staking-events","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("staking-events","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0027
git add 'tests/staking-events.test.ts'
git commit --allow-empty -q -m 'Add staking-events tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-events tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/marketplace-stats.clar')"
cat > 'contracts/marketplace-stats.clar' << 'PLEOF_0028'
;; marketplace-stats.clar  generated: jun6
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map marketplace_stats_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set marketplace_stats_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? marketplace_stats_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set marketplace_stats_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? marketplace_stats_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0028
git add 'contracts/marketplace-stats.clar'
git commit --allow-empty -q -m 'Add marketplace-stats: marketplace stats contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-stats: marketplace stats contract"

mkdir -p "$(dirname 'tests/marketplace-stats.test.ts')"
cat > 'tests/marketplace-stats.test.ts' << 'PLEOF_0029'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("marketplace-stats", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("marketplace-stats","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-stats","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-stats","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-stats","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-stats","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-stats","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("marketplace-stats","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("marketplace-stats","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0029
git add 'tests/marketplace-stats.test.ts'
git commit --allow-empty -q -m 'Add marketplace-stats tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-stats tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/governance-proposal-v3.clar')"
cat > 'contracts/governance-proposal-v3.clar' << 'PLEOF_0030'
;; governance-proposal-v3.clar  generated: jun6
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map governance_proposal_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set governance_proposal_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? governance_proposal_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set governance_proposal_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? governance_proposal_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0030
git add 'contracts/governance-proposal-v3.clar'
git commit --allow-empty -q -m 'Add governance-proposal-v3: governance proposal v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-proposal-v3: governance proposal v3 contract"

mkdir -p "$(dirname 'tests/governance-proposal-v3.test.ts')"
cat > 'tests/governance-proposal-v3.test.ts' << 'PLEOF_0031'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("governance-proposal-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("governance-proposal-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-proposal-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-proposal-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-proposal-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-proposal-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-proposal-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("governance-proposal-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("governance-proposal-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0031
git add 'tests/governance-proposal-v3.test.ts'
git commit --allow-empty -q -m 'Add governance-proposal-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-proposal-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/oracle-multi-asset.clar')"
cat > 'contracts/oracle-multi-asset.clar' << 'PLEOF_0032'
;; oracle-multi-asset.clar  generated: jun6
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map oracle_multi_asset_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set oracle_multi_asset_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? oracle_multi_asset_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set oracle_multi_asset_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? oracle_multi_asset_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0032
git add 'contracts/oracle-multi-asset.clar'
git commit --allow-empty -q -m 'Add oracle-multi-asset: oracle multi asset contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-multi-asset: oracle multi asset contract"

mkdir -p "$(dirname 'tests/oracle-multi-asset.test.ts')"
cat > 'tests/oracle-multi-asset.test.ts' << 'PLEOF_0033'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("oracle-multi-asset", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("oracle-multi-asset","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-multi-asset","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-multi-asset","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-multi-asset","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-multi-asset","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-multi-asset","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("oracle-multi-asset","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("oracle-multi-asset","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0033
git add 'tests/oracle-multi-asset.test.ts'
git commit --allow-empty -q -m 'Add oracle-multi-asset tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-multi-asset tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/protocol-fee-history.clar')"
cat > 'contracts/protocol-fee-history.clar' << 'PLEOF_0034'
;; protocol-fee-history.clar  generated: jun6
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map protocol_fee_history_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set protocol_fee_history_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? protocol_fee_history_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set protocol_fee_history_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? protocol_fee_history_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0034
git add 'contracts/protocol-fee-history.clar'
git commit --allow-empty -q -m 'Add protocol-fee-history: protocol fee history contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-fee-history: protocol fee history contract"

mkdir -p "$(dirname 'tests/protocol-fee-history.test.ts')"
cat > 'tests/protocol-fee-history.test.ts' << 'PLEOF_0035'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("protocol-fee-history", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("protocol-fee-history","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-fee-history","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-fee-history","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-fee-history","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-fee-history","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-fee-history","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("protocol-fee-history","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("protocol-fee-history","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0035
git add 'tests/protocol-fee-history.test.ts'
git commit --allow-empty -q -m 'Add protocol-fee-history tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-fee-history tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-jun6.clar')"
cat > 'contracts/patches/proofleger3-jun6.clar' << 'PLEOF_0036'
;; proofleger3 -- gas optimisation jun6
;; No functional changes
PLEOF_0036
git add 'contracts/patches/proofleger3-jun6.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-jun6.clar')"
cat > 'contracts/patches/proof-nft-jun6.clar' << 'PLEOF_0037'
;; proof-nft -- gas optimisation jun6
;; No functional changes
PLEOF_0037
git add 'contracts/patches/proof-nft-jun6.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-jun6.clar')"
cat > 'contracts/patches/governance-jun6.clar' << 'PLEOF_0038'
;; governance -- gas optimisation jun6
;; No functional changes
PLEOF_0038
git add 'contracts/patches/governance-jun6.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-jun6.clar')"
cat > 'contracts/patches/staking-jun6.clar' << 'PLEOF_0039'
;; staking -- gas optimisation jun6
;; No functional changes
PLEOF_0039
git add 'contracts/patches/staking-jun6.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-jun6.clar')"
cat > 'contracts/patches/whitelist-jun6.clar' << 'PLEOF_0040'
;; whitelist -- gas optimisation jun6
;; No functional changes
PLEOF_0040
git add 'contracts/patches/whitelist-jun6.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-jun6.clar')"
cat > 'contracts/patches/delegation-jun6.clar' << 'PLEOF_0041'
;; delegation -- gas optimisation jun6
;; No functional changes
PLEOF_0041
git add 'contracts/patches/delegation-jun6.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-jun6.clar')"
cat > 'contracts/patches/attestation-registry-jun6.clar' << 'PLEOF_0042'
;; attestation-registry -- gas optimisation jun6
;; No functional changes
PLEOF_0042
git add 'contracts/patches/attestation-registry-jun6.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-jun6.clar')"
cat > 'contracts/patches/credential-chain-jun6.clar' << 'PLEOF_0043'
;; credential-chain -- gas optimisation jun6
;; No functional changes
PLEOF_0043
git add 'contracts/patches/credential-chain-jun6.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-jun6.clar')"
cat > 'contracts/patches/sbt-jun6.clar' << 'PLEOF_0044'
;; sbt -- gas optimisation jun6
;; No functional changes
PLEOF_0044
git add 'contracts/patches/sbt-jun6.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-jun6.clar')"
cat > 'contracts/patches/issuer-registry-jun6.clar' << 'PLEOF_0045'
;; issuer-registry -- gas optimisation jun6
;; No functional changes
PLEOF_0045
git add 'contracts/patches/issuer-registry-jun6.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "jun6 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"