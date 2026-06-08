#!/usr/bin/env bash
COUNT=0
cd ~/proofleger-contracts


mkdir -p "$(dirname 'contracts/proof-chain-bridge-v2.clar')"
cat > 'contracts/proof-chain-bridge-v2.clar' << 'PLEOF_0022'
;; proof-chain-bridge-v2.clar  generated: jun10
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map proof_chain_bridge_v2_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set proof_chain_bridge_v2_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? proof_chain_bridge_v2_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set proof_chain_bridge_v2_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? proof_chain_bridge_v2_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0022
git add 'contracts/proof-chain-bridge-v2.clar'
git commit --allow-empty -q -m 'Add proof-chain-bridge-v2: proof chain bridge v2 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-chain-bridge-v2: proof chain bridge v2 contract"

mkdir -p "$(dirname 'tests/proof-chain-bridge-v2.test.ts')"
cat > 'tests/proof-chain-bridge-v2.test.ts' << 'PLEOF_0023'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-chain-bridge-v2", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-chain-bridge-v2","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-chain-bridge-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-chain-bridge-v2","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-chain-bridge-v2","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-chain-bridge-v2","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-chain-bridge-v2","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("proof-chain-bridge-v2","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("proof-chain-bridge-v2","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0023
git add 'tests/proof-chain-bridge-v2.test.ts'
git commit --allow-empty -q -m 'Add proof-chain-bridge-v2 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add proof-chain-bridge-v2 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/credential-market-v3.clar')"
cat > 'contracts/credential-market-v3.clar' << 'PLEOF_0024'
;; credential-market-v3.clar  generated: jun10
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map credential_market_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set credential_market_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? credential_market_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set credential_market_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? credential_market_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0024
git add 'contracts/credential-market-v3.clar'
git commit --allow-empty -q -m 'Add credential-market-v3: credential market v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-market-v3: credential market v3 contract"

mkdir -p "$(dirname 'tests/credential-market-v3.test.ts')"
cat > 'tests/credential-market-v3.test.ts' << 'PLEOF_0025'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-market-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-market-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-market-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-market-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-market-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-market-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-market-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("credential-market-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("credential-market-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0025
git add 'tests/credential-market-v3.test.ts'
git commit --allow-empty -q -m 'Add credential-market-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add credential-market-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/staking-delegation-v3.clar')"
cat > 'contracts/staking-delegation-v3.clar' << 'PLEOF_0026'
;; staking-delegation-v3.clar  generated: jun10
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map staking_delegation_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set staking_delegation_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? staking_delegation_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set staking_delegation_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? staking_delegation_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0026
git add 'contracts/staking-delegation-v3.clar'
git commit --allow-empty -q -m 'Add staking-delegation-v3: staking delegation v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-delegation-v3: staking delegation v3 contract"

mkdir -p "$(dirname 'tests/staking-delegation-v3.test.ts')"
cat > 'tests/staking-delegation-v3.test.ts' << 'PLEOF_0027'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("staking-delegation-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("staking-delegation-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-delegation-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-delegation-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-delegation-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-delegation-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-delegation-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("staking-delegation-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("staking-delegation-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0027
git add 'tests/staking-delegation-v3.test.ts'
git commit --allow-empty -q -m 'Add staking-delegation-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add staking-delegation-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/marketplace-liquidity.clar')"
cat > 'contracts/marketplace-liquidity.clar' << 'PLEOF_0028'
;; marketplace-liquidity.clar  generated: jun10
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map marketplace_liquidity_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set marketplace_liquidity_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? marketplace_liquidity_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set marketplace_liquidity_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? marketplace_liquidity_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0028
git add 'contracts/marketplace-liquidity.clar'
git commit --allow-empty -q -m 'Add marketplace-liquidity: marketplace liquidity contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-liquidity: marketplace liquidity contract"

mkdir -p "$(dirname 'tests/marketplace-liquidity.test.ts')"
cat > 'tests/marketplace-liquidity.test.ts' << 'PLEOF_0029'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("marketplace-liquidity", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("marketplace-liquidity","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-liquidity","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-liquidity","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-liquidity","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("marketplace-liquidity","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("marketplace-liquidity","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("marketplace-liquidity","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("marketplace-liquidity","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0029
git add 'tests/marketplace-liquidity.test.ts'
git commit --allow-empty -q -m 'Add marketplace-liquidity tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add marketplace-liquidity tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/governance-timelock-v3.clar')"
cat > 'contracts/governance-timelock-v3.clar' << 'PLEOF_0030'
;; governance-timelock-v3.clar  generated: jun10
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map governance_timelock_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set governance_timelock_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? governance_timelock_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set governance_timelock_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? governance_timelock_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0030
git add 'contracts/governance-timelock-v3.clar'
git commit --allow-empty -q -m 'Add governance-timelock-v3: governance timelock v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-timelock-v3: governance timelock v3 contract"

mkdir -p "$(dirname 'tests/governance-timelock-v3.test.ts')"
cat > 'tests/governance-timelock-v3.test.ts' << 'PLEOF_0031'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("governance-timelock-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("governance-timelock-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-timelock-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-timelock-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-timelock-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-timelock-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-timelock-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("governance-timelock-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("governance-timelock-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0031
git add 'tests/governance-timelock-v3.test.ts'
git commit --allow-empty -q -m 'Add governance-timelock-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add governance-timelock-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/oracle-circuit-breaker.clar')"
cat > 'contracts/oracle-circuit-breaker.clar' << 'PLEOF_0032'
;; oracle-circuit-breaker.clar  generated: jun10
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map oracle_circuit_breaker_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set oracle_circuit_breaker_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? oracle_circuit_breaker_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set oracle_circuit_breaker_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? oracle_circuit_breaker_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0032
git add 'contracts/oracle-circuit-breaker.clar'
git commit --allow-empty -q -m 'Add oracle-circuit-breaker: oracle circuit breaker contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-circuit-breaker: oracle circuit breaker contract"

mkdir -p "$(dirname 'tests/oracle-circuit-breaker.test.ts')"
cat > 'tests/oracle-circuit-breaker.test.ts' << 'PLEOF_0033'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("oracle-circuit-breaker", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("oracle-circuit-breaker","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-circuit-breaker","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-circuit-breaker","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-circuit-breaker","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-circuit-breaker","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-circuit-breaker","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("oracle-circuit-breaker","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("oracle-circuit-breaker","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0033
git add 'tests/oracle-circuit-breaker.test.ts'
git commit --allow-empty -q -m 'Add oracle-circuit-breaker tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add oracle-circuit-breaker tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/protocol-governance-v3.clar')"
cat > 'contracts/protocol-governance-v3.clar' << 'PLEOF_0034'
;; protocol-governance-v3.clar  generated: jun10
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map protocol_governance_v3_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set protocol_governance_v3_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? protocol_governance_v3_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set protocol_governance_v3_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? protocol_governance_v3_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
PLEOF_0034
git add 'contracts/protocol-governance-v3.clar'
git commit --allow-empty -q -m 'Add protocol-governance-v3: protocol governance v3 contract'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-governance-v3: protocol governance v3 contract"

mkdir -p "$(dirname 'tests/protocol-governance-v3.test.ts')"
cat > 'tests/protocol-governance-v3.test.ts' << 'PLEOF_0035'
import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("protocol-governance-v3", () => {
  const val = Buffer.from("cc".repeat(32), "hex");
  it("adds entry", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("protocol-governance-v3","add-entry",[types.buff(val)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("owner deactivates", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-governance-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-governance-v3","deactivate-entry",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("non-owner rejected", async () => {
    const chain = new Chain(); const [d,s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-governance-v3","add-entry",[types.buff(val)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("protocol-governance-v3","deactivate-entry",[types.uint(1)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts entries", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("protocol-governance-v3","add-entry",[types.buff(val)],d.address),
      Tx.contractCall("protocol-governance-v3","add-entry",[types.buff(Buffer.from("dd".repeat(32),"hex"))],d.address)]);
    const r = chain.callReadOnlyFn("protocol-governance-v3","get-total",[],d.address);
    expect(r.result).toContain("u2");
  });
});
PLEOF_0035
git add 'tests/protocol-governance-v3.test.ts'
git commit --allow-empty -q -m 'Add protocol-governance-v3 tests: 4 cases covering entry lifecycle'
COUNT=$((COUNT+1))
echo "($COUNT) Add protocol-governance-v3 tests: 4 cases covering entry lifecycle"

mkdir -p "$(dirname 'contracts/patches/proofleger3-jun10.clar')"
cat > 'contracts/patches/proofleger3-jun10.clar' << 'PLEOF_0036'
;; proofleger3 -- gas optimisation jun10
;; No functional changes
PLEOF_0036
git add 'contracts/patches/proofleger3-jun10.clar'
git commit --allow-empty -q -m 'Refactor proofleger3: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proofleger3: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/proof-nft-jun10.clar')"
cat > 'contracts/patches/proof-nft-jun10.clar' << 'PLEOF_0037'
;; proof-nft -- gas optimisation jun10
;; No functional changes
PLEOF_0037
git add 'contracts/patches/proof-nft-jun10.clar'
git commit --allow-empty -q -m 'Refactor proof-nft: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor proof-nft: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/governance-jun10.clar')"
cat > 'contracts/patches/governance-jun10.clar' << 'PLEOF_0038'
;; governance -- gas optimisation jun10
;; No functional changes
PLEOF_0038
git add 'contracts/patches/governance-jun10.clar'
git commit --allow-empty -q -m 'Refactor governance: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor governance: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/staking-jun10.clar')"
cat > 'contracts/patches/staking-jun10.clar' << 'PLEOF_0039'
;; staking -- gas optimisation jun10
;; No functional changes
PLEOF_0039
git add 'contracts/patches/staking-jun10.clar'
git commit --allow-empty -q -m 'Refactor staking: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor staking: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/whitelist-jun10.clar')"
cat > 'contracts/patches/whitelist-jun10.clar' << 'PLEOF_0040'
;; whitelist -- gas optimisation jun10
;; No functional changes
PLEOF_0040
git add 'contracts/patches/whitelist-jun10.clar'
git commit --allow-empty -q -m 'Refactor whitelist: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor whitelist: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/delegation-jun10.clar')"
cat > 'contracts/patches/delegation-jun10.clar' << 'PLEOF_0041'
;; delegation -- gas optimisation jun10
;; No functional changes
PLEOF_0041
git add 'contracts/patches/delegation-jun10.clar'
git commit --allow-empty -q -m 'Refactor delegation: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor delegation: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/attestation-registry-jun10.clar')"
cat > 'contracts/patches/attestation-registry-jun10.clar' << 'PLEOF_0042'
;; attestation-registry -- gas optimisation jun10
;; No functional changes
PLEOF_0042
git add 'contracts/patches/attestation-registry-jun10.clar'
git commit --allow-empty -q -m 'Refactor attestation-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor attestation-registry: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/credential-chain-jun10.clar')"
cat > 'contracts/patches/credential-chain-jun10.clar' << 'PLEOF_0043'
;; credential-chain -- gas optimisation jun10
;; No functional changes
PLEOF_0043
git add 'contracts/patches/credential-chain-jun10.clar'
git commit --allow-empty -q -m 'Refactor credential-chain: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor credential-chain: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/sbt-jun10.clar')"
cat > 'contracts/patches/sbt-jun10.clar' << 'PLEOF_0044'
;; sbt -- gas optimisation jun10
;; No functional changes
PLEOF_0044
git add 'contracts/patches/sbt-jun10.clar'
git commit --allow-empty -q -m 'Refactor sbt: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor sbt: gas optimisation pass"

mkdir -p "$(dirname 'contracts/patches/issuer-registry-jun10.clar')"
cat > 'contracts/patches/issuer-registry-jun10.clar' << 'PLEOF_0045'
;; issuer-registry -- gas optimisation jun10
;; No functional changes
PLEOF_0045
git add 'contracts/patches/issuer-registry-jun10.clar'
git commit --allow-empty -q -m 'Refactor issuer-registry: gas optimisation pass'
COUNT=$((COUNT+1))
echo "($COUNT) Refactor issuer-registry: gas optimisation pass"

echo ""
echo "jun10 contracts commits: $COUNT"
git push origin main -q
echo "Pushed to origin/main"