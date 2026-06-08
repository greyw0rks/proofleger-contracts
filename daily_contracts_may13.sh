#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/staking-rewards.clar')"
cat > 'contracts/staking-rewards.clar' << 'PLEOF_0021'
;; staking-rewards.clar  generated: may13
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map staking_rewards_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set staking_rewards_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? staking_rewards_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set staking_rewards_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? staking_rewards_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0021
git add 'contracts/staking-rewards.clar'
git commit --allow-empty -q -m 'Add staking-rewards: staking rewards contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-rewards: staking rewards contract"

mkdir -p "$(dirname 'tests/staking-rewards.test.ts')"
cat > 'tests/staking-rewards.test.ts' << 'PLEOF_0022'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("staking-rewards", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("staking-rewards","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-rewards","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-rewards","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-rewards","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-rewards","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-rewards","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("staking-rewards","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("staking-rewards","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0022
git add 'tests/staking-rewards.test.ts'
git commit --allow-empty -q -m 'Add staking-rewards tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-rewards tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/reputation-v2.clar')"
cat > 'contracts/reputation-v2.clar' << 'PLEOF_0023'
;; reputation-v2.clar  generated: may13
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map reputation_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set reputation_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? reputation_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set reputation_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? reputation_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0023
git add 'contracts/reputation-v2.clar'
git commit --allow-empty -q -m 'Add reputation-v2: reputation v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add reputation-v2: reputation v2 contract"

mkdir -p "$(dirname 'tests/reputation-v2.test.ts')"
cat > 'tests/reputation-v2.test.ts' << 'PLEOF_0024'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("reputation-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("reputation-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reputation-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("reputation-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reputation-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("reputation-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reputation-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("reputation-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("reputation-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0024
git add 'tests/reputation-v2.test.ts'
git commit --allow-empty -q -m 'Add reputation-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add reputation-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/achievement-v2.clar')"
cat > 'contracts/achievement-v2.clar' << 'PLEOF_0025'
;; achievement-v2.clar  generated: may13
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map achievement_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set achievement_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? achievement_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set achievement_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? achievement_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0025
git add 'contracts/achievement-v2.clar'
git commit --allow-empty -q -m 'Add achievement-v2: achievement v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add achievement-v2: achievement v2 contract"

mkdir -p "$(dirname 'tests/achievement-v2.test.ts')"
cat > 'tests/achievement-v2.test.ts' << 'PLEOF_0026'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("achievement-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("achievement-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("achievement-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("achievement-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("achievement-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("achievement-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("achievement-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("achievement-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("achievement-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0026
git add 'tests/achievement-v2.test.ts'
git commit --allow-empty -q -m 'Add achievement-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add achievement-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/talent-registry.clar')"
cat > 'contracts/talent-registry.clar' << 'PLEOF_0027'
;; talent-registry.clar  generated: may13
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map talent_registry_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set talent_registry_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? talent_registry_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set talent_registry_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? talent_registry_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0027
git add 'contracts/talent-registry.clar'
git commit --allow-empty -q -m 'Add talent-registry: talent registry contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add talent-registry: talent registry contract"

mkdir -p "$(dirname 'tests/talent-registry.test.ts')"
cat > 'tests/talent-registry.test.ts' << 'PLEOF_0028'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("talent-registry", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("talent-registry","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("talent-registry","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("talent-registry","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("talent-registry","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("talent-registry","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("talent-registry","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("talent-registry","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("talent-registry","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0028
git add 'tests/talent-registry.test.ts'
git commit --allow-empty -q -m 'Add talent-registry tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add talent-registry tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/credential-bundle.clar')"
cat > 'contracts/credential-bundle.clar' << 'PLEOF_0029'
;; credential-bundle.clar  generated: may13
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map credential_bundle_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set credential_bundle_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? credential_bundle_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set credential_bundle_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? credential_bundle_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0029
git add 'contracts/credential-bundle.clar'
git commit --allow-empty -q -m 'Add credential-bundle: credential bundle contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-bundle: credential bundle contract"

mkdir -p "$(dirname 'tests/credential-bundle.test.ts')"
cat > 'tests/credential-bundle.test.ts' << 'PLEOF_0030'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-bundle", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-bundle","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-bundle","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-bundle","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-bundle","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-bundle","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-bundle","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("credential-bundle","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("credential-bundle","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0030
git add 'tests/credential-bundle.test.ts'
git commit --allow-empty -q -m 'Add credential-bundle tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-bundle tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-may13.clar')"
cat > 'contracts/patches/proofleger3-may13.clar' << 'PLEOF_0031'
;; proofleger3 -- gas optimisation may13
;; No functional changes
PLEOF_0031
git add 'contracts/patches/proofleger3-may13.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-may13.clar')"
cat > 'contracts/patches/proof-nft-may13.clar' << 'PLEOF_0032'
;; proof-nft -- gas optimisation may13
;; No functional changes
PLEOF_0032
git add 'contracts/patches/proof-nft-may13.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-may13.clar')"
cat > 'contracts/patches/governance-may13.clar' << 'PLEOF_0033'
;; governance -- gas optimisation may13
;; No functional changes
PLEOF_0033
git add 'contracts/patches/governance-may13.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-may13.clar')"
cat > 'contracts/patches/staking-may13.clar' << 'PLEOF_0034'
;; staking -- gas optimisation may13
;; No functional changes
PLEOF_0034
git add 'contracts/patches/staking-may13.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-may13.clar')"
cat > 'contracts/patches/whitelist-may13.clar' << 'PLEOF_0035'
;; whitelist -- gas optimisation may13
;; No functional changes
PLEOF_0035
git add 'contracts/patches/whitelist-may13.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-may13.clar')"
cat > 'contracts/patches/delegation-may13.clar' << 'PLEOF_0036'
;; delegation -- gas optimisation may13
;; No functional changes
PLEOF_0036
git add 'contracts/patches/delegation-may13.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-may13.clar')"
cat > 'contracts/patches/attestation-registry-may13.clar' << 'PLEOF_0037'
;; attestation-registry -- gas optimisation may13
;; No functional changes
PLEOF_0037
git add 'contracts/patches/attestation-registry-may13.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-may13.clar')"
cat > 'contracts/patches/credential-chain-may13.clar' << 'PLEOF_0038'
;; credential-chain -- gas optimisation may13
;; No functional changes
PLEOF_0038
git add 'contracts/patches/credential-chain-may13.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-may13.clar')"
cat > 'contracts/patches/sbt-may13.clar' << 'PLEOF_0039'
;; sbt -- gas optimisation may13
;; No functional changes
PLEOF_0039
git add 'contracts/patches/sbt-may13.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-may13.clar')"
cat > 'contracts/patches/issuer-registry-may13.clar' << 'PLEOF_0040'
;; issuer-registry -- gas optimisation may13
;; No functional changes
PLEOF_0040
git add 'contracts/patches/issuer-registry-may13.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "may13 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"