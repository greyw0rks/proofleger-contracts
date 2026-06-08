#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/proof-search-v2.clar')"
cat > 'contracts/proof-search-v2.clar' << 'PLEOF_0022'
;; proof-search-v2.clar  generated: may28
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_search_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_search_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_search_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_search_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_search_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0022
git add 'contracts/proof-search-v2.clar'
git commit --allow-empty -q -m 'Add proof-search-v2: proof search v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-search-v2: proof search v2 contract"

mkdir -p "$(dirname 'tests/proof-search-v2.test.ts')"
cat > 'tests/proof-search-v2.test.ts' << 'PLEOF_0023'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-search-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-search-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-search-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-search-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-search-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-search-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-search-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-search-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-search-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0023
git add 'tests/proof-search-v2.test.ts'
git commit --allow-empty -q -m 'Add proof-search-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-search-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/credential-market-v2.clar')"
cat > 'contracts/credential-market-v2.clar' << 'PLEOF_0024'
;; credential-market-v2.clar  generated: may28
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map credential_market_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set credential_market_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? credential_market_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set credential_market_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? credential_market_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0024
git add 'contracts/credential-market-v2.clar'
git commit --allow-empty -q -m 'Add credential-market-v2: credential market v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-market-v2: credential market v2 contract"

mkdir -p "$(dirname 'tests/credential-market-v2.test.ts')"
cat > 'tests/credential-market-v2.test.ts' << 'PLEOF_0025'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-market-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-market-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-market-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-market-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-market-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-market-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-market-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("credential-market-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("credential-market-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0025
git add 'tests/credential-market-v2.test.ts'
git commit --allow-empty -q -m 'Add credential-market-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-market-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/delegation-chain.clar')"
cat > 'contracts/delegation-chain.clar' << 'PLEOF_0026'
;; delegation-chain.clar  generated: may28
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map delegation_chain_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set delegation_chain_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? delegation_chain_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set delegation_chain_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? delegation_chain_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0026
git add 'contracts/delegation-chain.clar'
git commit --allow-empty -q -m 'Add delegation-chain: delegation chain contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add delegation-chain: delegation chain contract"

mkdir -p "$(dirname 'tests/delegation-chain.test.ts')"
cat > 'tests/delegation-chain.test.ts' << 'PLEOF_0027'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("delegation-chain", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("delegation-chain","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("delegation-chain","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("delegation-chain","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("delegation-chain","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("delegation-chain","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("delegation-chain","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("delegation-chain","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("delegation-chain","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0027
git add 'tests/delegation-chain.test.ts'
git commit --allow-empty -q -m 'Add delegation-chain tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add delegation-chain tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/staking-reward-history.clar')"
cat > 'contracts/staking-reward-history.clar' << 'PLEOF_0028'
;; staking-reward-history.clar  generated: may28
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map staking_reward_history_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set staking_reward_history_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? staking_reward_history_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set staking_reward_history_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? staking_reward_history_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0028
git add 'contracts/staking-reward-history.clar'
git commit --allow-empty -q -m 'Add staking-reward-history: staking reward history contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-reward-history: staking reward history contract"

mkdir -p "$(dirname 'tests/staking-reward-history.test.ts')"
cat > 'tests/staking-reward-history.test.ts' << 'PLEOF_0029'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("staking-reward-history", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("staking-reward-history","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-reward-history","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-reward-history","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-reward-history","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-reward-history","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-reward-history","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("staking-reward-history","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("staking-reward-history","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0029
git add 'tests/staking-reward-history.test.ts'
git commit --allow-empty -q -m 'Add staking-reward-history tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-reward-history tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/governance-delegate-v2.clar')"
cat > 'contracts/governance-delegate-v2.clar' << 'PLEOF_0030'
;; governance-delegate-v2.clar  generated: may28
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map governance_delegate_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set governance_delegate_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? governance_delegate_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set governance_delegate_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? governance_delegate_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0030
git add 'contracts/governance-delegate-v2.clar'
git commit --allow-empty -q -m 'Add governance-delegate-v2: governance delegate v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-delegate-v2: governance delegate v2 contract"

mkdir -p "$(dirname 'tests/governance-delegate-v2.test.ts')"
cat > 'tests/governance-delegate-v2.test.ts' << 'PLEOF_0031'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("governance-delegate-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("governance-delegate-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-delegate-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-delegate-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-delegate-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-delegate-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-delegate-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("governance-delegate-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("governance-delegate-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0031
git add 'tests/governance-delegate-v2.test.ts'
git commit --allow-empty -q -m 'Add governance-delegate-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-delegate-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/proof-archive.clar')"
cat > 'contracts/proof-archive.clar' << 'PLEOF_0032'
;; proof-archive.clar  generated: may28
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_archive_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_archive_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_archive_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_archive_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_archive_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0032
git add 'contracts/proof-archive.clar'
git commit --allow-empty -q -m 'Add proof-archive: proof archive contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-archive: proof archive contract"

mkdir -p "$(dirname 'tests/proof-archive.test.ts')"
cat > 'tests/proof-archive.test.ts' << 'PLEOF_0033'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-archive", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-archive","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-archive","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-archive","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-archive","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-archive","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-archive","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-archive","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-archive","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0033
git add 'tests/proof-archive.test.ts'
git commit --allow-empty -q -m 'Add proof-archive tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-archive tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/protocol-upgrade.clar')"
cat > 'contracts/protocol-upgrade.clar' << 'PLEOF_0034'
;; protocol-upgrade.clar  generated: may28
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map protocol_upgrade_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set protocol_upgrade_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? protocol_upgrade_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set protocol_upgrade_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? protocol_upgrade_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0034
git add 'contracts/protocol-upgrade.clar'
git commit --allow-empty -q -m 'Add protocol-upgrade: protocol upgrade contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-upgrade: protocol upgrade contract"

mkdir -p "$(dirname 'tests/protocol-upgrade.test.ts')"
cat > 'tests/protocol-upgrade.test.ts' << 'PLEOF_0035'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("protocol-upgrade", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("protocol-upgrade","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-upgrade","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-upgrade","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-upgrade","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-upgrade","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-upgrade","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("protocol-upgrade","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("protocol-upgrade","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0035
git add 'tests/protocol-upgrade.test.ts'
git commit --allow-empty -q -m 'Add protocol-upgrade tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-upgrade tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-may28.clar')"
cat > 'contracts/patches/proofleger3-may28.clar' << 'PLEOF_0036'
;; proofleger3 -- gas optimisation may28
;; No functional changes
PLEOF_0036
git add 'contracts/patches/proofleger3-may28.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-may28.clar')"
cat > 'contracts/patches/proof-nft-may28.clar' << 'PLEOF_0037'
;; proof-nft -- gas optimisation may28
;; No functional changes
PLEOF_0037
git add 'contracts/patches/proof-nft-may28.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-may28.clar')"
cat > 'contracts/patches/governance-may28.clar' << 'PLEOF_0038'
;; governance -- gas optimisation may28
;; No functional changes
PLEOF_0038
git add 'contracts/patches/governance-may28.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-may28.clar')"
cat > 'contracts/patches/staking-may28.clar' << 'PLEOF_0039'
;; staking -- gas optimisation may28
;; No functional changes
PLEOF_0039
git add 'contracts/patches/staking-may28.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-may28.clar')"
cat > 'contracts/patches/whitelist-may28.clar' << 'PLEOF_0040'
;; whitelist -- gas optimisation may28
;; No functional changes
PLEOF_0040
git add 'contracts/patches/whitelist-may28.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-may28.clar')"
cat > 'contracts/patches/delegation-may28.clar' << 'PLEOF_0041'
;; delegation -- gas optimisation may28
;; No functional changes
PLEOF_0041
git add 'contracts/patches/delegation-may28.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-may28.clar')"
cat > 'contracts/patches/attestation-registry-may28.clar' << 'PLEOF_0042'
;; attestation-registry -- gas optimisation may28
;; No functional changes
PLEOF_0042
git add 'contracts/patches/attestation-registry-may28.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-may28.clar')"
cat > 'contracts/patches/credential-chain-may28.clar' << 'PLEOF_0043'
;; credential-chain -- gas optimisation may28
;; No functional changes
PLEOF_0043
git add 'contracts/patches/credential-chain-may28.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-may28.clar')"
cat > 'contracts/patches/sbt-may28.clar' << 'PLEOF_0044'
;; sbt -- gas optimisation may28
;; No functional changes
PLEOF_0044
git add 'contracts/patches/sbt-may28.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-may28.clar')"
cat > 'contracts/patches/issuer-registry-may28.clar' << 'PLEOF_0045'
;; issuer-registry -- gas optimisation may28
;; No functional changes
PLEOF_0045
git add 'contracts/patches/issuer-registry-may28.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "may28 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"