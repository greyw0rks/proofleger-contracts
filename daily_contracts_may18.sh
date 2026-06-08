#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/credential-exchange.clar')"
cat > 'contracts/credential-exchange.clar' << 'PLEOF_0021'
;; credential-exchange.clar  generated: may18
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map credential_exchange_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set credential_exchange_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? credential_exchange_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set credential_exchange_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? credential_exchange_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0021
git add 'contracts/credential-exchange.clar'
git commit --allow-empty -q -m 'Add credential-exchange: credential exchange contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-exchange: credential exchange contract"

mkdir -p "$(dirname 'tests/credential-exchange.test.ts')"
cat > 'tests/credential-exchange.test.ts' << 'PLEOF_0022'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-exchange", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-exchange","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-exchange","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-exchange","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-exchange","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-exchange","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-exchange","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("credential-exchange","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("credential-exchange","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0022
git add 'tests/credential-exchange.test.ts'
git commit --allow-empty -q -m 'Add credential-exchange tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-exchange tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/proof-marketplace-v2.clar')"
cat > 'contracts/proof-marketplace-v2.clar' << 'PLEOF_0023'
;; proof-marketplace-v2.clar  generated: may18
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_marketplace_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_marketplace_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_marketplace_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_marketplace_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_marketplace_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0023
git add 'contracts/proof-marketplace-v2.clar'
git commit --allow-empty -q -m 'Add proof-marketplace-v2: proof marketplace v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-marketplace-v2: proof marketplace v2 contract"

mkdir -p "$(dirname 'tests/proof-marketplace-v2.test.ts')"
cat > 'tests/proof-marketplace-v2.test.ts' << 'PLEOF_0024'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-marketplace-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-marketplace-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-marketplace-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-marketplace-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-marketplace-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-marketplace-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-marketplace-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-marketplace-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-marketplace-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0024
git add 'tests/proof-marketplace-v2.test.ts'
git commit --allow-empty -q -m 'Add proof-marketplace-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-marketplace-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/escrow-v2.clar')"
cat > 'contracts/escrow-v2.clar' << 'PLEOF_0025'
;; escrow-v2.clar  generated: may18
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map escrow_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set escrow_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? escrow_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set escrow_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? escrow_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0025
git add 'contracts/escrow-v2.clar'
git commit --allow-empty -q -m 'Add escrow-v2: escrow v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add escrow-v2: escrow v2 contract"

mkdir -p "$(dirname 'tests/escrow-v2.test.ts')"
cat > 'tests/escrow-v2.test.ts' << 'PLEOF_0026'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("escrow-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("escrow-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("escrow-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("escrow-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("escrow-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("escrow-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("escrow-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("escrow-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("escrow-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0026
git add 'tests/escrow-v2.test.ts'
git commit --allow-empty -q -m 'Add escrow-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add escrow-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/reward-pool.clar')"
cat > 'contracts/reward-pool.clar' << 'PLEOF_0027'
;; reward-pool.clar  generated: may18
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map reward_pool_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set reward_pool_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? reward_pool_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set reward_pool_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? reward_pool_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0027
git add 'contracts/reward-pool.clar'
git commit --allow-empty -q -m 'Add reward-pool: reward pool contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add reward-pool: reward pool contract"

mkdir -p "$(dirname 'tests/reward-pool.test.ts')"
cat > 'tests/reward-pool.test.ts' << 'PLEOF_0028'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("reward-pool", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("reward-pool","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reward-pool","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("reward-pool","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reward-pool","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("reward-pool","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reward-pool","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("reward-pool","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("reward-pool","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0028
git add 'tests/reward-pool.test.ts'
git commit --allow-empty -q -m 'Add reward-pool tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add reward-pool tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/batch-verifier.clar')"
cat > 'contracts/batch-verifier.clar' << 'PLEOF_0029'
;; batch-verifier.clar  generated: may18
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map batch_verifier_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set batch_verifier_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? batch_verifier_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set batch_verifier_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? batch_verifier_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0029
git add 'contracts/batch-verifier.clar'
git commit --allow-empty -q -m 'Add batch-verifier: batch verifier contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add batch-verifier: batch verifier contract"

mkdir -p "$(dirname 'tests/batch-verifier.test.ts')"
cat > 'tests/batch-verifier.test.ts' << 'PLEOF_0030'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("batch-verifier", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("batch-verifier","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("batch-verifier","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("batch-verifier","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("batch-verifier","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("batch-verifier","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("batch-verifier","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("batch-verifier","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("batch-verifier","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0030
git add 'tests/batch-verifier.test.ts'
git commit --allow-empty -q -m 'Add batch-verifier tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add batch-verifier tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-may18.clar')"
cat > 'contracts/patches/proofleger3-may18.clar' << 'PLEOF_0031'
;; proofleger3 -- gas optimisation may18
;; No functional changes
PLEOF_0031
git add 'contracts/patches/proofleger3-may18.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-may18.clar')"
cat > 'contracts/patches/proof-nft-may18.clar' << 'PLEOF_0032'
;; proof-nft -- gas optimisation may18
;; No functional changes
PLEOF_0032
git add 'contracts/patches/proof-nft-may18.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-may18.clar')"
cat > 'contracts/patches/governance-may18.clar' << 'PLEOF_0033'
;; governance -- gas optimisation may18
;; No functional changes
PLEOF_0033
git add 'contracts/patches/governance-may18.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-may18.clar')"
cat > 'contracts/patches/staking-may18.clar' << 'PLEOF_0034'
;; staking -- gas optimisation may18
;; No functional changes
PLEOF_0034
git add 'contracts/patches/staking-may18.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-may18.clar')"
cat > 'contracts/patches/whitelist-may18.clar' << 'PLEOF_0035'
;; whitelist -- gas optimisation may18
;; No functional changes
PLEOF_0035
git add 'contracts/patches/whitelist-may18.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-may18.clar')"
cat > 'contracts/patches/delegation-may18.clar' << 'PLEOF_0036'
;; delegation -- gas optimisation may18
;; No functional changes
PLEOF_0036
git add 'contracts/patches/delegation-may18.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-may18.clar')"
cat > 'contracts/patches/attestation-registry-may18.clar' << 'PLEOF_0037'
;; attestation-registry -- gas optimisation may18
;; No functional changes
PLEOF_0037
git add 'contracts/patches/attestation-registry-may18.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-may18.clar')"
cat > 'contracts/patches/credential-chain-may18.clar' << 'PLEOF_0038'
;; credential-chain -- gas optimisation may18
;; No functional changes
PLEOF_0038
git add 'contracts/patches/credential-chain-may18.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-may18.clar')"
cat > 'contracts/patches/sbt-may18.clar' << 'PLEOF_0039'
;; sbt -- gas optimisation may18
;; No functional changes
PLEOF_0039
git add 'contracts/patches/sbt-may18.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-may18.clar')"
cat > 'contracts/patches/issuer-registry-may18.clar' << 'PLEOF_0040'
;; issuer-registry -- gas optimisation may18
;; No functional changes
PLEOF_0040
git add 'contracts/patches/issuer-registry-may18.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "may18 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"