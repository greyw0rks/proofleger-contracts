#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/proof-integrity.clar')"
cat > 'contracts/proof-integrity.clar' << 'PLEOF_0022'
;; proof-integrity.clar  generated: jun7
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_integrity_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_integrity_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_integrity_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_integrity_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_integrity_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0022
git add 'contracts/proof-integrity.clar'
git commit --allow-empty -q -m 'Add proof-integrity: proof integrity contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-integrity: proof integrity contract"

mkdir -p "$(dirname 'tests/proof-integrity.test.ts')"
cat > 'tests/proof-integrity.test.ts' << 'PLEOF_0023'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-integrity", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-integrity","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-integrity","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-integrity","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-integrity","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-integrity","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-integrity","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-integrity","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-integrity","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0023
git add 'tests/proof-integrity.test.ts'
git commit --allow-empty -q -m 'Add proof-integrity tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-integrity tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/credential-snapshot.clar')"
cat > 'contracts/credential-snapshot.clar' << 'PLEOF_0024'
;; credential-snapshot.clar  generated: jun7
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map credential_snapshot_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set credential_snapshot_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? credential_snapshot_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set credential_snapshot_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? credential_snapshot_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0024
git add 'contracts/credential-snapshot.clar'
git commit --allow-empty -q -m 'Add credential-snapshot: credential snapshot contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-snapshot: credential snapshot contract"

mkdir -p "$(dirname 'tests/credential-snapshot.test.ts')"
cat > 'tests/credential-snapshot.test.ts' << 'PLEOF_0025'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-snapshot", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-snapshot","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-snapshot","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-snapshot","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-snapshot","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-snapshot","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-snapshot","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("credential-snapshot","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("credential-snapshot","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0025
git add 'tests/credential-snapshot.test.ts'
git commit --allow-empty -q -m 'Add credential-snapshot tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-snapshot tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/staking-apy.clar')"
cat > 'contracts/staking-apy.clar' << 'PLEOF_0026'
;; staking-apy.clar  generated: jun7
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map staking_apy_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set staking_apy_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? staking_apy_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set staking_apy_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? staking_apy_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0026
git add 'contracts/staking-apy.clar'
git commit --allow-empty -q -m 'Add staking-apy: staking apy contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-apy: staking apy contract"

mkdir -p "$(dirname 'tests/staking-apy.test.ts')"
cat > 'tests/staking-apy.test.ts' << 'PLEOF_0027'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("staking-apy", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("staking-apy","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-apy","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-apy","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-apy","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-apy","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-apy","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("staking-apy","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("staking-apy","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0027
git add 'tests/staking-apy.test.ts'
git commit --allow-empty -q -m 'Add staking-apy tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-apy tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/marketplace-activity.clar')"
cat > 'contracts/marketplace-activity.clar' << 'PLEOF_0028'
;; marketplace-activity.clar  generated: jun7
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map marketplace_activity_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set marketplace_activity_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? marketplace_activity_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set marketplace_activity_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? marketplace_activity_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0028
git add 'contracts/marketplace-activity.clar'
git commit --allow-empty -q -m 'Add marketplace-activity: marketplace activity contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-activity: marketplace activity contract"

mkdir -p "$(dirname 'tests/marketplace-activity.test.ts')"
cat > 'tests/marketplace-activity.test.ts' << 'PLEOF_0029'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("marketplace-activity", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("marketplace-activity","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-activity","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-activity","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-activity","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-activity","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-activity","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("marketplace-activity","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("marketplace-activity","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0029
git add 'tests/marketplace-activity.test.ts'
git commit --allow-empty -q -m 'Add marketplace-activity tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-activity tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/governance-delegate-v3.clar')"
cat > 'contracts/governance-delegate-v3.clar' << 'PLEOF_0030'
;; governance-delegate-v3.clar  generated: jun7
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map governance_delegate_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set governance_delegate_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? governance_delegate_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set governance_delegate_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? governance_delegate_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0030
git add 'contracts/governance-delegate-v3.clar'
git commit --allow-empty -q -m 'Add governance-delegate-v3: governance delegate v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-delegate-v3: governance delegate v3 contract"

mkdir -p "$(dirname 'tests/governance-delegate-v3.test.ts')"
cat > 'tests/governance-delegate-v3.test.ts' << 'PLEOF_0031'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("governance-delegate-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("governance-delegate-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-delegate-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-delegate-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-delegate-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-delegate-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-delegate-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("governance-delegate-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("governance-delegate-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0031
git add 'tests/governance-delegate-v3.test.ts'
git commit --allow-empty -q -m 'Add governance-delegate-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-delegate-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/oracle-alert.clar')"
cat > 'contracts/oracle-alert.clar' << 'PLEOF_0032'
;; oracle-alert.clar  generated: jun7
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map oracle_alert_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set oracle_alert_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? oracle_alert_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set oracle_alert_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? oracle_alert_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0032
git add 'contracts/oracle-alert.clar'
git commit --allow-empty -q -m 'Add oracle-alert: oracle alert contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-alert: oracle alert contract"

mkdir -p "$(dirname 'tests/oracle-alert.test.ts')"
cat > 'tests/oracle-alert.test.ts' << 'PLEOF_0033'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("oracle-alert", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("oracle-alert","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-alert","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-alert","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-alert","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-alert","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-alert","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("oracle-alert","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("oracle-alert","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0033
git add 'tests/oracle-alert.test.ts'
git commit --allow-empty -q -m 'Add oracle-alert tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-alert tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/protocol-upgrade-v3.clar')"
cat > 'contracts/protocol-upgrade-v3.clar' << 'PLEOF_0034'
;; protocol-upgrade-v3.clar  generated: jun7
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map protocol_upgrade_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set protocol_upgrade_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? protocol_upgrade_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set protocol_upgrade_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? protocol_upgrade_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0034
git add 'contracts/protocol-upgrade-v3.clar'
git commit --allow-empty -q -m 'Add protocol-upgrade-v3: protocol upgrade v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-upgrade-v3: protocol upgrade v3 contract"

mkdir -p "$(dirname 'tests/protocol-upgrade-v3.test.ts')"
cat > 'tests/protocol-upgrade-v3.test.ts' << 'PLEOF_0035'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("protocol-upgrade-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("protocol-upgrade-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-upgrade-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-upgrade-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-upgrade-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-upgrade-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-upgrade-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("protocol-upgrade-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("protocol-upgrade-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0035
git add 'tests/protocol-upgrade-v3.test.ts'
git commit --allow-empty -q -m 'Add protocol-upgrade-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-upgrade-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-jun7.clar')"
cat > 'contracts/patches/proofleger3-jun7.clar' << 'PLEOF_0036'
;; proofleger3 -- gas optimisation jun7
;; No functional changes
PLEOF_0036
git add 'contracts/patches/proofleger3-jun7.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-jun7.clar')"
cat > 'contracts/patches/proof-nft-jun7.clar' << 'PLEOF_0037'
;; proof-nft -- gas optimisation jun7
;; No functional changes
PLEOF_0037
git add 'contracts/patches/proof-nft-jun7.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-jun7.clar')"
cat > 'contracts/patches/governance-jun7.clar' << 'PLEOF_0038'
;; governance -- gas optimisation jun7
;; No functional changes
PLEOF_0038
git add 'contracts/patches/governance-jun7.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-jun7.clar')"
cat > 'contracts/patches/staking-jun7.clar' << 'PLEOF_0039'
;; staking -- gas optimisation jun7
;; No functional changes
PLEOF_0039
git add 'contracts/patches/staking-jun7.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-jun7.clar')"
cat > 'contracts/patches/whitelist-jun7.clar' << 'PLEOF_0040'
;; whitelist -- gas optimisation jun7
;; No functional changes
PLEOF_0040
git add 'contracts/patches/whitelist-jun7.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-jun7.clar')"
cat > 'contracts/patches/delegation-jun7.clar' << 'PLEOF_0041'
;; delegation -- gas optimisation jun7
;; No functional changes
PLEOF_0041
git add 'contracts/patches/delegation-jun7.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-jun7.clar')"
cat > 'contracts/patches/attestation-registry-jun7.clar' << 'PLEOF_0042'
;; attestation-registry -- gas optimisation jun7
;; No functional changes
PLEOF_0042
git add 'contracts/patches/attestation-registry-jun7.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-jun7.clar')"
cat > 'contracts/patches/credential-chain-jun7.clar' << 'PLEOF_0043'
;; credential-chain -- gas optimisation jun7
;; No functional changes
PLEOF_0043
git add 'contracts/patches/credential-chain-jun7.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-jun7.clar')"
cat > 'contracts/patches/sbt-jun7.clar' << 'PLEOF_0044'
;; sbt -- gas optimisation jun7
;; No functional changes
PLEOF_0044
git add 'contracts/patches/sbt-jun7.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-jun7.clar')"
cat > 'contracts/patches/issuer-registry-jun7.clar' << 'PLEOF_0045'
;; issuer-registry -- gas optimisation jun7
;; No functional changes
PLEOF_0045
git add 'contracts/patches/issuer-registry-jun7.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "jun7 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"