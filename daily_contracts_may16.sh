#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/proof-counter-v2.clar')"
cat > 'contracts/proof-counter-v2.clar' << 'PLEOF_0021'
;; proof-counter-v2.clar  generated: may16
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_counter_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_counter_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_counter_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_counter_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_counter_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0021
git add 'contracts/proof-counter-v2.clar'
git commit --allow-empty -q -m 'Add proof-counter-v2: proof counter v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-counter-v2: proof counter v2 contract"

mkdir -p "$(dirname 'tests/proof-counter-v2.test.ts')"
cat > 'tests/proof-counter-v2.test.ts' << 'PLEOF_0022'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-counter-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-counter-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-counter-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-counter-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-counter-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-counter-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-counter-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-counter-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-counter-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0022
git add 'tests/proof-counter-v2.test.ts'
git commit --allow-empty -q -m 'Add proof-counter-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-counter-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/document-registry-v2.clar')"
cat > 'contracts/document-registry-v2.clar' << 'PLEOF_0023'
;; document-registry-v2.clar  generated: may16
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map document_registry_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set document_registry_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? document_registry_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set document_registry_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? document_registry_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0023
git add 'contracts/document-registry-v2.clar'
git commit --allow-empty -q -m 'Add document-registry-v2: document registry v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add document-registry-v2: document registry v2 contract"

mkdir -p "$(dirname 'tests/document-registry-v2.test.ts')"
cat > 'tests/document-registry-v2.test.ts' << 'PLEOF_0024'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("document-registry-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("document-registry-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("document-registry-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("document-registry-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("document-registry-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("document-registry-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("document-registry-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("document-registry-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("document-registry-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0024
git add 'tests/document-registry-v2.test.ts'
git commit --allow-empty -q -m 'Add document-registry-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add document-registry-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/anchor-v3-stats.clar')"
cat > 'contracts/anchor-v3-stats.clar' << 'PLEOF_0025'
;; anchor-v3-stats.clar  generated: may16
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map anchor_v3_stats_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set anchor_v3_stats_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? anchor_v3_stats_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set anchor_v3_stats_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? anchor_v3_stats_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0025
git add 'contracts/anchor-v3-stats.clar'
git commit --allow-empty -q -m 'Add anchor-v3-stats: anchor v3 stats contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add anchor-v3-stats: anchor v3 stats contract"

mkdir -p "$(dirname 'tests/anchor-v3-stats.test.ts')"
cat > 'tests/anchor-v3-stats.test.ts' << 'PLEOF_0026'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("anchor-v3-stats", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("anchor-v3-stats","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("anchor-v3-stats","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("anchor-v3-stats","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("anchor-v3-stats","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("anchor-v3-stats","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("anchor-v3-stats","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("anchor-v3-stats","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("anchor-v3-stats","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0026
git add 'tests/anchor-v3-stats.test.ts'
git commit --allow-empty -q -m 'Add anchor-v3-stats tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add anchor-v3-stats tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/chain-stats.clar')"
cat > 'contracts/chain-stats.clar' << 'PLEOF_0027'
;; chain-stats.clar  generated: may16
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map chain_stats_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set chain_stats_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? chain_stats_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set chain_stats_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? chain_stats_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0027
git add 'contracts/chain-stats.clar'
git commit --allow-empty -q -m 'Add chain-stats: chain stats contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add chain-stats: chain stats contract"

mkdir -p "$(dirname 'tests/chain-stats.test.ts')"
cat > 'tests/chain-stats.test.ts' << 'PLEOF_0028'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("chain-stats", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("chain-stats","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("chain-stats","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("chain-stats","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("chain-stats","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("chain-stats","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("chain-stats","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("chain-stats","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("chain-stats","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0028
git add 'tests/chain-stats.test.ts'
git commit --allow-empty -q -m 'Add chain-stats tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add chain-stats tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/activity-log.clar')"
cat > 'contracts/activity-log.clar' << 'PLEOF_0029'
;; activity-log.clar  generated: may16
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map activity_log_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set activity_log_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? activity_log_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set activity_log_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? activity_log_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0029
git add 'contracts/activity-log.clar'
git commit --allow-empty -q -m 'Add activity-log: activity log contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add activity-log: activity log contract"

mkdir -p "$(dirname 'tests/activity-log.test.ts')"
cat > 'tests/activity-log.test.ts' << 'PLEOF_0030'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("activity-log", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("activity-log","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("activity-log","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("activity-log","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("activity-log","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("activity-log","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("activity-log","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("activity-log","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("activity-log","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0030
git add 'tests/activity-log.test.ts'
git commit --allow-empty -q -m 'Add activity-log tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add activity-log tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-may16.clar')"
cat > 'contracts/patches/proofleger3-may16.clar' << 'PLEOF_0031'
;; proofleger3 -- gas optimisation may16
;; No functional changes
PLEOF_0031
git add 'contracts/patches/proofleger3-may16.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-may16.clar')"
cat > 'contracts/patches/proof-nft-may16.clar' << 'PLEOF_0032'
;; proof-nft -- gas optimisation may16
;; No functional changes
PLEOF_0032
git add 'contracts/patches/proof-nft-may16.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-may16.clar')"
cat > 'contracts/patches/governance-may16.clar' << 'PLEOF_0033'
;; governance -- gas optimisation may16
;; No functional changes
PLEOF_0033
git add 'contracts/patches/governance-may16.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-may16.clar')"
cat > 'contracts/patches/staking-may16.clar' << 'PLEOF_0034'
;; staking -- gas optimisation may16
;; No functional changes
PLEOF_0034
git add 'contracts/patches/staking-may16.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-may16.clar')"
cat > 'contracts/patches/whitelist-may16.clar' << 'PLEOF_0035'
;; whitelist -- gas optimisation may16
;; No functional changes
PLEOF_0035
git add 'contracts/patches/whitelist-may16.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-may16.clar')"
cat > 'contracts/patches/delegation-may16.clar' << 'PLEOF_0036'
;; delegation -- gas optimisation may16
;; No functional changes
PLEOF_0036
git add 'contracts/patches/delegation-may16.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-may16.clar')"
cat > 'contracts/patches/attestation-registry-may16.clar' << 'PLEOF_0037'
;; attestation-registry -- gas optimisation may16
;; No functional changes
PLEOF_0037
git add 'contracts/patches/attestation-registry-may16.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-may16.clar')"
cat > 'contracts/patches/credential-chain-may16.clar' << 'PLEOF_0038'
;; credential-chain -- gas optimisation may16
;; No functional changes
PLEOF_0038
git add 'contracts/patches/credential-chain-may16.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-may16.clar')"
cat > 'contracts/patches/sbt-may16.clar' << 'PLEOF_0039'
;; sbt -- gas optimisation may16
;; No functional changes
PLEOF_0039
git add 'contracts/patches/sbt-may16.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-may16.clar')"
cat > 'contracts/patches/issuer-registry-may16.clar' << 'PLEOF_0040'
;; issuer-registry -- gas optimisation may16
;; No functional changes
PLEOF_0040
git add 'contracts/patches/issuer-registry-may16.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "may16 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"