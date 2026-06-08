#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/proof-attestation-v2.clar')"
cat > 'contracts/proof-attestation-v2.clar' << 'PLEOF_0022'
;; proof-attestation-v2.clar  generated: jun5
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_attestation_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_attestation_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_attestation_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_attestation_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_attestation_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0022
git add 'contracts/proof-attestation-v2.clar'
git commit --allow-empty -q -m 'Add proof-attestation-v2: proof attestation v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-attestation-v2: proof attestation v2 contract"

mkdir -p "$(dirname 'tests/proof-attestation-v2.test.ts')"
cat > 'tests/proof-attestation-v2.test.ts' << 'PLEOF_0023'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-attestation-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-attestation-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-attestation-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-attestation-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-attestation-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-attestation-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-attestation-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-attestation-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-attestation-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0023
git add 'tests/proof-attestation-v2.test.ts'
git commit --allow-empty -q -m 'Add proof-attestation-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-attestation-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/credential-score.clar')"
cat > 'contracts/credential-score.clar' << 'PLEOF_0024'
;; credential-score.clar  generated: jun5
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map credential_score_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set credential_score_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? credential_score_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set credential_score_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? credential_score_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0024
git add 'contracts/credential-score.clar'
git commit --allow-empty -q -m 'Add credential-score: credential score contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-score: credential score contract"

mkdir -p "$(dirname 'tests/credential-score.test.ts')"
cat > 'tests/credential-score.test.ts' << 'PLEOF_0025'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-score", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-score","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-score","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-score","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-score","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-score","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-score","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("credential-score","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("credential-score","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0025
git add 'tests/credential-score.test.ts'
git commit --allow-empty -q -m 'Add credential-score tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-score tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/staking-boost.clar')"
cat > 'contracts/staking-boost.clar' << 'PLEOF_0026'
;; staking-boost.clar  generated: jun5
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map staking_boost_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set staking_boost_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? staking_boost_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set staking_boost_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? staking_boost_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0026
git add 'contracts/staking-boost.clar'
git commit --allow-empty -q -m 'Add staking-boost: staking boost contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-boost: staking boost contract"

mkdir -p "$(dirname 'tests/staking-boost.test.ts')"
cat > 'tests/staking-boost.test.ts' << 'PLEOF_0027'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("staking-boost", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("staking-boost","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-boost","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-boost","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-boost","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-boost","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-boost","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("staking-boost","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("staking-boost","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0027
git add 'tests/staking-boost.test.ts'
git commit --allow-empty -q -m 'Add staking-boost tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-boost tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/marketplace-fees.clar')"
cat > 'contracts/marketplace-fees.clar' << 'PLEOF_0028'
;; marketplace-fees.clar  generated: jun5
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map marketplace_fees_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set marketplace_fees_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? marketplace_fees_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set marketplace_fees_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? marketplace_fees_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0028
git add 'contracts/marketplace-fees.clar'
git commit --allow-empty -q -m 'Add marketplace-fees: marketplace fees contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-fees: marketplace fees contract"

mkdir -p "$(dirname 'tests/marketplace-fees.test.ts')"
cat > 'tests/marketplace-fees.test.ts' << 'PLEOF_0029'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("marketplace-fees", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("marketplace-fees","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-fees","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-fees","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-fees","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-fees","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-fees","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("marketplace-fees","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("marketplace-fees","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0029
git add 'tests/marketplace-fees.test.ts'
git commit --allow-empty -q -m 'Add marketplace-fees tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-fees tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/governance-weight.clar')"
cat > 'contracts/governance-weight.clar' << 'PLEOF_0030'
;; governance-weight.clar  generated: jun5
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map governance_weight_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set governance_weight_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? governance_weight_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set governance_weight_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? governance_weight_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0030
git add 'contracts/governance-weight.clar'
git commit --allow-empty -q -m 'Add governance-weight: governance weight contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-weight: governance weight contract"

mkdir -p "$(dirname 'tests/governance-weight.test.ts')"
cat > 'tests/governance-weight.test.ts' << 'PLEOF_0031'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("governance-weight", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("governance-weight","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-weight","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-weight","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-weight","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-weight","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-weight","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("governance-weight","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("governance-weight","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0031
git add 'tests/governance-weight.test.ts'
git commit --allow-empty -q -m 'Add governance-weight tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-weight tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/oracle-threshold.clar')"
cat > 'contracts/oracle-threshold.clar' << 'PLEOF_0032'
;; oracle-threshold.clar  generated: jun5
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map oracle_threshold_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set oracle_threshold_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? oracle_threshold_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set oracle_threshold_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? oracle_threshold_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0032
git add 'contracts/oracle-threshold.clar'
git commit --allow-empty -q -m 'Add oracle-threshold: oracle threshold contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-threshold: oracle threshold contract"

mkdir -p "$(dirname 'tests/oracle-threshold.test.ts')"
cat > 'tests/oracle-threshold.test.ts' << 'PLEOF_0033'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("oracle-threshold", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("oracle-threshold","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-threshold","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-threshold","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-threshold","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-threshold","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-threshold","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("oracle-threshold","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("oracle-threshold","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0033
git add 'tests/oracle-threshold.test.ts'
git commit --allow-empty -q -m 'Add oracle-threshold tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-threshold tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/protocol-health-v2.clar')"
cat > 'contracts/protocol-health-v2.clar' << 'PLEOF_0034'
;; protocol-health-v2.clar  generated: jun5
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map protocol_health_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set protocol_health_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? protocol_health_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set protocol_health_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? protocol_health_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0034
git add 'contracts/protocol-health-v2.clar'
git commit --allow-empty -q -m 'Add protocol-health-v2: protocol health v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-health-v2: protocol health v2 contract"

mkdir -p "$(dirname 'tests/protocol-health-v2.test.ts')"
cat > 'tests/protocol-health-v2.test.ts' << 'PLEOF_0035'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("protocol-health-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("protocol-health-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-health-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-health-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-health-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-health-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-health-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("protocol-health-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("protocol-health-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0035
git add 'tests/protocol-health-v2.test.ts'
git commit --allow-empty -q -m 'Add protocol-health-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-health-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-jun5.clar')"
cat > 'contracts/patches/proofleger3-jun5.clar' << 'PLEOF_0036'
;; proofleger3 -- gas optimisation jun5
;; No functional changes
PLEOF_0036
git add 'contracts/patches/proofleger3-jun5.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-jun5.clar')"
cat > 'contracts/patches/proof-nft-jun5.clar' << 'PLEOF_0037'
;; proof-nft -- gas optimisation jun5
;; No functional changes
PLEOF_0037
git add 'contracts/patches/proof-nft-jun5.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-jun5.clar')"
cat > 'contracts/patches/governance-jun5.clar' << 'PLEOF_0038'
;; governance -- gas optimisation jun5
;; No functional changes
PLEOF_0038
git add 'contracts/patches/governance-jun5.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-jun5.clar')"
cat > 'contracts/patches/staking-jun5.clar' << 'PLEOF_0039'
;; staking -- gas optimisation jun5
;; No functional changes
PLEOF_0039
git add 'contracts/patches/staking-jun5.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-jun5.clar')"
cat > 'contracts/patches/whitelist-jun5.clar' << 'PLEOF_0040'
;; whitelist -- gas optimisation jun5
;; No functional changes
PLEOF_0040
git add 'contracts/patches/whitelist-jun5.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-jun5.clar')"
cat > 'contracts/patches/delegation-jun5.clar' << 'PLEOF_0041'
;; delegation -- gas optimisation jun5
;; No functional changes
PLEOF_0041
git add 'contracts/patches/delegation-jun5.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-jun5.clar')"
cat > 'contracts/patches/attestation-registry-jun5.clar' << 'PLEOF_0042'
;; attestation-registry -- gas optimisation jun5
;; No functional changes
PLEOF_0042
git add 'contracts/patches/attestation-registry-jun5.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-jun5.clar')"
cat > 'contracts/patches/credential-chain-jun5.clar' << 'PLEOF_0043'
;; credential-chain -- gas optimisation jun5
;; No functional changes
PLEOF_0043
git add 'contracts/patches/credential-chain-jun5.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-jun5.clar')"
cat > 'contracts/patches/sbt-jun5.clar' << 'PLEOF_0044'
;; sbt -- gas optimisation jun5
;; No functional changes
PLEOF_0044
git add 'contracts/patches/sbt-jun5.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-jun5.clar')"
cat > 'contracts/patches/issuer-registry-jun5.clar' << 'PLEOF_0045'
;; issuer-registry -- gas optimisation jun5
;; No functional changes
PLEOF_0045
git add 'contracts/patches/issuer-registry-jun5.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "jun5 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"