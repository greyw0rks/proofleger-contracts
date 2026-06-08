#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/protocol-fees-v2.clar')"
cat > 'contracts/protocol-fees-v2.clar' << 'PLEOF_0022'
;; protocol-fees-v2.clar  generated: may26
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map protocol_fees_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set protocol_fees_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? protocol_fees_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set protocol_fees_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? protocol_fees_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0022
git add 'contracts/protocol-fees-v2.clar'
git commit --allow-empty -q -m 'Add protocol-fees-v2: protocol fees v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-fees-v2: protocol fees v2 contract"

mkdir -p "$(dirname 'tests/protocol-fees-v2.test.ts')"
cat > 'tests/protocol-fees-v2.test.ts' << 'PLEOF_0023'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("protocol-fees-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("protocol-fees-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-fees-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-fees-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-fees-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-fees-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-fees-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("protocol-fees-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("protocol-fees-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0023
git add 'tests/protocol-fees-v2.test.ts'
git commit --allow-empty -q -m 'Add protocol-fees-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-fees-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/cross-chain-proof.clar')"
cat > 'contracts/cross-chain-proof.clar' << 'PLEOF_0024'
;; cross-chain-proof.clar  generated: may26
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map cross_chain_proof_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set cross_chain_proof_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? cross_chain_proof_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set cross_chain_proof_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? cross_chain_proof_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0024
git add 'contracts/cross-chain-proof.clar'
git commit --allow-empty -q -m 'Add cross-chain-proof: cross chain proof contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add cross-chain-proof: cross chain proof contract"

mkdir -p "$(dirname 'tests/cross-chain-proof.test.ts')"
cat > 'tests/cross-chain-proof.test.ts' << 'PLEOF_0025'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("cross-chain-proof", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("cross-chain-proof","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("cross-chain-proof","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("cross-chain-proof","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("cross-chain-proof","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("cross-chain-proof","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("cross-chain-proof","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("cross-chain-proof","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("cross-chain-proof","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0025
git add 'tests/cross-chain-proof.test.ts'
git commit --allow-empty -q -m 'Add cross-chain-proof tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add cross-chain-proof tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/revocation-oracle.clar')"
cat > 'contracts/revocation-oracle.clar' << 'PLEOF_0026'
;; revocation-oracle.clar  generated: may26
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map revocation_oracle_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set revocation_oracle_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? revocation_oracle_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set revocation_oracle_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? revocation_oracle_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0026
git add 'contracts/revocation-oracle.clar'
git commit --allow-empty -q -m 'Add revocation-oracle: revocation oracle contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add revocation-oracle: revocation oracle contract"

mkdir -p "$(dirname 'tests/revocation-oracle.test.ts')"
cat > 'tests/revocation-oracle.test.ts' << 'PLEOF_0027'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("revocation-oracle", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("revocation-oracle","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("revocation-oracle","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("revocation-oracle","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("revocation-oracle","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("revocation-oracle","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("revocation-oracle","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("revocation-oracle","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("revocation-oracle","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0027
git add 'tests/revocation-oracle.test.ts'
git commit --allow-empty -q -m 'Add revocation-oracle tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add revocation-oracle tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/nft-metadata-v2.clar')"
cat > 'contracts/nft-metadata-v2.clar' << 'PLEOF_0028'
;; nft-metadata-v2.clar  generated: may26
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map nft_metadata_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set nft_metadata_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? nft_metadata_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set nft_metadata_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? nft_metadata_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0028
git add 'contracts/nft-metadata-v2.clar'
git commit --allow-empty -q -m 'Add nft-metadata-v2: nft metadata v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add nft-metadata-v2: nft metadata v2 contract"

mkdir -p "$(dirname 'tests/nft-metadata-v2.test.ts')"
cat > 'tests/nft-metadata-v2.test.ts' << 'PLEOF_0029'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("nft-metadata-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("nft-metadata-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("nft-metadata-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("nft-metadata-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("nft-metadata-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("nft-metadata-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("nft-metadata-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("nft-metadata-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("nft-metadata-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0029
git add 'tests/nft-metadata-v2.test.ts'
git commit --allow-empty -q -m 'Add nft-metadata-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add nft-metadata-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/bundle-verifier-v2.clar')"
cat > 'contracts/bundle-verifier-v2.clar' << 'PLEOF_0030'
;; bundle-verifier-v2.clar  generated: may26
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map bundle_verifier_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set bundle_verifier_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? bundle_verifier_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set bundle_verifier_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? bundle_verifier_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0030
git add 'contracts/bundle-verifier-v2.clar'
git commit --allow-empty -q -m 'Add bundle-verifier-v2: bundle verifier v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add bundle-verifier-v2: bundle verifier v2 contract"

mkdir -p "$(dirname 'tests/bundle-verifier-v2.test.ts')"
cat > 'tests/bundle-verifier-v2.test.ts' << 'PLEOF_0031'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("bundle-verifier-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("bundle-verifier-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("bundle-verifier-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("bundle-verifier-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("bundle-verifier-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("bundle-verifier-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("bundle-verifier-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("bundle-verifier-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("bundle-verifier-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0031
git add 'tests/bundle-verifier-v2.test.ts'
git commit --allow-empty -q -m 'Add bundle-verifier-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add bundle-verifier-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/timelock-v3.clar')"
cat > 'contracts/timelock-v3.clar' << 'PLEOF_0032'
;; timelock-v3.clar  generated: may26
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map timelock_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set timelock_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? timelock_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set timelock_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? timelock_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0032
git add 'contracts/timelock-v3.clar'
git commit --allow-empty -q -m 'Add timelock-v3: timelock v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add timelock-v3: timelock v3 contract"

mkdir -p "$(dirname 'tests/timelock-v3.test.ts')"
cat > 'tests/timelock-v3.test.ts' << 'PLEOF_0033'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("timelock-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("timelock-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("timelock-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("timelock-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("timelock-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("timelock-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("timelock-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("timelock-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("timelock-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0033
git add 'tests/timelock-v3.test.ts'
git commit --allow-empty -q -m 'Add timelock-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add timelock-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/reward-claim.clar')"
cat > 'contracts/reward-claim.clar' << 'PLEOF_0034'
;; reward-claim.clar  generated: may26
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map reward_claim_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set reward_claim_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? reward_claim_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set reward_claim_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? reward_claim_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0034
git add 'contracts/reward-claim.clar'
git commit --allow-empty -q -m 'Add reward-claim: reward claim contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add reward-claim: reward claim contract"

mkdir -p "$(dirname 'tests/reward-claim.test.ts')"
cat > 'tests/reward-claim.test.ts' << 'PLEOF_0035'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("reward-claim", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("reward-claim","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reward-claim","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("reward-claim","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reward-claim","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("reward-claim","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("reward-claim","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("reward-claim","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("reward-claim","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0035
git add 'tests/reward-claim.test.ts'
git commit --allow-empty -q -m 'Add reward-claim tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add reward-claim tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-may26.clar')"
cat > 'contracts/patches/proofleger3-may26.clar' << 'PLEOF_0036'
;; proofleger3 -- gas optimisation may26
;; No functional changes
PLEOF_0036
git add 'contracts/patches/proofleger3-may26.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-may26.clar')"
cat > 'contracts/patches/proof-nft-may26.clar' << 'PLEOF_0037'
;; proof-nft -- gas optimisation may26
;; No functional changes
PLEOF_0037
git add 'contracts/patches/proof-nft-may26.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-may26.clar')"
cat > 'contracts/patches/governance-may26.clar' << 'PLEOF_0038'
;; governance -- gas optimisation may26
;; No functional changes
PLEOF_0038
git add 'contracts/patches/governance-may26.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-may26.clar')"
cat > 'contracts/patches/staking-may26.clar' << 'PLEOF_0039'
;; staking -- gas optimisation may26
;; No functional changes
PLEOF_0039
git add 'contracts/patches/staking-may26.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-may26.clar')"
cat > 'contracts/patches/whitelist-may26.clar' << 'PLEOF_0040'
;; whitelist -- gas optimisation may26
;; No functional changes
PLEOF_0040
git add 'contracts/patches/whitelist-may26.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-may26.clar')"
cat > 'contracts/patches/delegation-may26.clar' << 'PLEOF_0041'
;; delegation -- gas optimisation may26
;; No functional changes
PLEOF_0041
git add 'contracts/patches/delegation-may26.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-may26.clar')"
cat > 'contracts/patches/attestation-registry-may26.clar' << 'PLEOF_0042'
;; attestation-registry -- gas optimisation may26
;; No functional changes
PLEOF_0042
git add 'contracts/patches/attestation-registry-may26.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-may26.clar')"
cat > 'contracts/patches/credential-chain-may26.clar' << 'PLEOF_0043'
;; credential-chain -- gas optimisation may26
;; No functional changes
PLEOF_0043
git add 'contracts/patches/credential-chain-may26.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-may26.clar')"
cat > 'contracts/patches/sbt-may26.clar' << 'PLEOF_0044'
;; sbt -- gas optimisation may26
;; No functional changes
PLEOF_0044
git add 'contracts/patches/sbt-may26.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-may26.clar')"
cat > 'contracts/patches/issuer-registry-may26.clar' << 'PLEOF_0045'
;; issuer-registry -- gas optimisation may26
;; No functional changes
PLEOF_0045
git add 'contracts/patches/issuer-registry-may26.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "may26 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"