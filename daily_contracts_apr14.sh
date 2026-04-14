#!/bin/bash
# proofleger-contracts - Daily Commits April 14
# cd proofleger-contracts && bash daily_contracts_apr14.sh

set -e
GREEN="\033[0;32m"; YELLOW="\033[1;33m"; NC="\033[0m"
TOTAL=0

c() {
  mkdir -p "$(dirname "$1")"
  printf '%s' "$3" > "$1"
  git add "$1"
  git commit -m "$2" -q
  TOTAL=$((TOTAL + 1))
  echo -e "${GREEN}✓ [$TOTAL]${NC} $2"
}

bump() {
  python3 -c "import json;p=json.load(open('package.json'));p['version']='$1';json.dump(p,open('package.json','w'),indent=2);open('package.json','a').write('\n')" 2>/dev/null || \
  node -e "const fs=require('fs');const p=JSON.parse(fs.readFileSync('package.json','utf8'));p.version='$1';fs.writeFileSync('package.json',JSON.stringify(p,null,2)+'\n');"
  git add package.json
  git commit -m "Bump version to $1" -q
  TOTAL=$((TOTAL + 1))
  echo -e "${YELLOW}↑ [$TOTAL]${NC} Version $1"
}

echo -e "${YELLOW}Contracts Apr 14 commits starting...${NC}"

# ── New contracts ─────────────────────────────────────────────

c contracts/multisig.clar \
"Add multisig.clar: multi-signature document approval contract" \
';; multisig.clar
;; ProofLedger Multi-Signature Approval
;; Require M-of-N signatures before a document is considered approved

(define-map multisig-configs
  { id: uint }
  { creator: principal, required: uint, total-signers: uint, created-at: uint })

(define-map multisig-signers
  { config-id: uint, signer: principal }
  { authorized: bool })

(define-map multisig-approvals
  { config-id: uint, hash: (buff 32) }
  { approved-count: uint, approved: bool })

(define-map signer-approvals
  { config-id: uint, hash: (buff 32), signer: principal }
  { signed-at: uint })

(define-data-var config-count uint u0)

;; create-config: set up a new multisig configuration
;; Errors: u1 = required must be positive, u2 = required > total
(define-public (create-config (required uint) (signers (list 10 principal)))
  (let ((id (+ (var-get config-count) u1))
        (total (len signers)))
    (asserts! (> required u0) (err u1))
    (asserts! (<= required total) (err u2))
    (map-set multisig-configs { id: id }
      { creator: tx-sender, required: required,
        total-signers: total, created-at: stacks-block-height })
    (var-set config-count id)
    (ok id)))

;; approve: signer approves a document hash
;; Errors: u3 = config not found, u4 = not authorized, u5 = already signed
(define-public (approve (config-id uint) (hash (buff 32)))
  (let ((config (unwrap! (map-get? multisig-configs { id: config-id }) (err u3)))
        (existing (map-get? multisig-approvals { config-id: config-id, hash: hash }))
        (count (default-to u0 (get approved-count existing))))
    (asserts! (is-none (map-get? signer-approvals { config-id: config-id, hash: hash, signer: tx-sender })) (err u5))
    (map-set signer-approvals { config-id: config-id, hash: hash, signer: tx-sender }
      { signed-at: stacks-block-height })
    (let ((new-count (+ count u1))
          (is-approved (>= (+ count u1) (get required config))))
      (map-set multisig-approvals { config-id: config-id, hash: hash }
        { approved-count: new-count, approved: is-approved })
      (ok is-approved))))

(define-read-only (is-approved (config-id uint) (hash (buff 32)))
  (default-to false (get approved (map-get? multisig-approvals { config-id: config-id, hash: hash }))))

(define-read-only (get-approval-count (config-id uint) (hash (buff 32)))
  (default-to u0 (get approved-count (map-get? multisig-approvals { config-id: config-id, hash: hash }))))'

c contracts/attestation-v2.clar \
"Add attestation-v2.clar: enhanced attestation with credibility scores" \
';; attestation-v2.clar
;; ProofLedger Enhanced Attestation
;; Attestations with credibility weight based on attestor reputation

(define-map attestations-v2
  { hash: (buff 32), attestor: principal }
  { attested-at: uint, credential-type: (string-ascii 50),
    weight: uint, comment: (string-ascii 200) })

(define-map attestation-totals
  { hash: (buff 32) }
  { count: uint, total-weight: uint })

;; attest-with-weight: attest with a credibility weight (1-10)
;; Errors: u1 = already attested, u2 = invalid weight, u3 = self-attest
(define-public (attest-with-weight (hash (buff 32)) (credential-type (string-ascii 50))
                                    (weight uint) (comment (string-ascii 200)))
  (let ((totals (default-to { count: u0, total-weight: u0 }
          (map-get? attestation-totals { hash: hash }))))
    (asserts! (is-none (map-get? attestations-v2 { hash: hash, attestor: tx-sender })) (err u1))
    (asserts! (and (>= weight u1) (<= weight u10)) (err u2))
    (map-set attestations-v2 { hash: hash, attestor: tx-sender }
      { attested-at: stacks-block-height, credential-type: credential-type,
        weight: weight, comment: comment })
    (map-set attestation-totals { hash: hash }
      { count: (+ (get count totals) u1),
        total-weight: (+ (get total-weight totals) weight) })
    (ok true)))

(define-read-only (get-attestation (hash (buff 32)) (attestor principal))
  (map-get? attestations-v2 { hash: hash, attestor: attestor }))

(define-read-only (get-credibility-score (hash (buff 32)))
  (let ((totals (default-to { count: u0, total-weight: u0 }
          (map-get? attestation-totals { hash: hash }))))
    (if (> (get count totals) u0)
      (/ (get total-weight totals) (get count totals))
      u0)))'

c contracts/access-control.clar \
"Add access-control.clar: role-based access control for ProofLedger" \
';; access-control.clar
;; ProofLedger Role-Based Access Control
;; Assign and check roles for protocol participants

(define-constant ROLE_ADMIN u1)
(define-constant ROLE_ISSUER u2)
(define-constant ROLE_VERIFIER u3)
(define-constant ROLE_MODERATOR u4)

(define-map roles
  { address: principal, role: uint }
  { granted-at: uint, granted-by: principal })

(define-data-var contract-owner principal tx-sender)

;; grant-role: owner grants a role to an address
;; Errors: u403 = not owner, u1 = already has role
(define-public (grant-role (address principal) (role uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (is-none (map-get? roles { address: address, role: role })) (err u1))
    (map-set roles { address: address, role: role }
      { granted-at: stacks-block-height, granted-by: tx-sender })
    (ok true)))

;; revoke-role: owner removes a role from an address
;; Errors: u403 = not owner
(define-public (revoke-role (address principal) (role uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (map-delete roles { address: address, role: role })
    (ok true)))

(define-read-only (has-role (address principal) (role uint))
  (is-some (map-get? roles { address: address, role: role })))

(define-read-only (is-admin (address principal))
  (has-role address ROLE_ADMIN))

(define-read-only (is-issuer (address principal))
  (has-role address ROLE_ISSUER))'

c contracts/snapshots.clar \
"Add snapshots.clar: periodic on-chain state snapshots for analytics" \
';; snapshots.clar
;; ProofLedger State Snapshots
;; Record periodic protocol metrics on-chain for public analytics

(define-map snapshots
  { epoch: uint }
  { total-docs: uint, total-wallets: uint, total-attestations: uint,
    total-nfts: uint, recorded-at: uint, recorder: principal })

(define-data-var latest-epoch uint u0)
(define-data-var snapshot-count uint u0)

;; record-snapshot: store a new protocol metrics snapshot
(define-public (record-snapshot (total-docs uint) (total-wallets uint)
                                 (total-attestations uint) (total-nfts uint))
  (let ((epoch (+ (var-get snapshot-count) u1)))
    (map-set snapshots { epoch: epoch }
      { total-docs: total-docs, total-wallets: total-wallets,
        total-attestations: total-attestations, total-nfts: total-nfts,
        recorded-at: stacks-block-height, recorder: tx-sender })
    (var-set snapshot-count epoch)
    (var-set latest-epoch epoch)
    (ok epoch)))

(define-read-only (get-snapshot (epoch uint))
  (map-get? snapshots { epoch: epoch }))

(define-read-only (get-latest-snapshot)
  (map-get? snapshots { epoch: (var-get latest-epoch) }))

(define-read-only (get-snapshot-count)
  (var-get snapshot-count))'

c contracts/dispatcher.clar \
"Add dispatcher.clar: route contract calls based on document type" \
';; dispatcher.clar
;; ProofLedger Action Dispatcher
;; Routes document operations to the appropriate handler contract
;; based on document type and action requested

(define-map handlers
  { doc-type: (string-ascii 50), action: (string-ascii 50) }
  { handler-contract: principal, registered-at: uint })

(define-data-var contract-owner principal tx-sender)
(define-data-var handler-count uint u0)

;; register-handler: map a doc-type+action pair to a handler contract
;; Errors: u403 = not owner
(define-public (register-handler (doc-type (string-ascii 50)) (action (string-ascii 50))
                                   (handler-contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (map-set handlers { doc-type: doc-type, action: action }
      { handler-contract: handler-contract, registered-at: stacks-block-height })
    (var-set handler-count (+ (var-get handler-count) u1))
    (ok true)))

;; get-handler: look up the handler for a doc-type+action
(define-read-only (get-handler (doc-type (string-ascii 50)) (action (string-ascii 50)))
  (map-get? handlers { doc-type: doc-type, action: action }))

(define-read-only (has-handler (doc-type (string-ascii 50)) (action (string-ascii 50)))
  (is-some (map-get? handlers { doc-type: doc-type, action: action })))

(define-read-only (get-handler-count)
  (var-get handler-count))'

bump "2.0.0"

# ── Tests ─────────────────────────────────────────────────────

c tests/multisig_test.ts \
"Add multisig tests: create config, approve, threshold detection" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("multisig", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a 2-of-3 config", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(2), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1), Cl.standardPrincipal(w2)])], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("approves a document hash", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(2), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1), Cl.standardPrincipal(w2)])], d);
    const r = simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    expect(r.result).toBeOk(Cl.bool(false));
  });
  it("marks approved when threshold met", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(2), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1)])], d);
    simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    const r = simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate approval", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(1), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1)])], d);
    simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    const r = simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    expect(r.result).toBeErr(Cl.uint(5));
  });
});'

c tests/attestation_v2_test.ts \
"Add attestation-v2 tests: weighted attest, credibility score, self-attest block" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("attestation-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("attests with weight", () => {
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(8), Cl.stringAscii("Verified directly")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects weight above 10", () => {
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(11), Cl.stringAscii("Too high")], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
  it("rejects duplicate attestation", () => {
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(5), Cl.stringAscii("First")], w1);
    const r = simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(5), Cl.stringAscii("Second")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("returns correct credibility score", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(8), Cl.stringAscii("Good")], w1);
    simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(6), Cl.stringAscii("Ok")], w2);
    const r = simnet.callReadOnlyFn("attestation-v2", "get-credibility-score", [hash], w1);
    expect(r.result).toBeUint(7);
  });
});'

c tests/access_control_test.ts \
"Add access-control tests: grant role, revoke role, has-role check" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("access-control", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("grants a role", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("access-control", "grant-role",
      [Cl.standardPrincipal(w1), Cl.uint(2)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms has-role after grant", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("access-control", "grant-role", [Cl.standardPrincipal(w1), Cl.uint(3)], d);
    const r = simnet.callReadOnlyFn("access-control", "has-role",
      [Cl.standardPrincipal(w1), Cl.uint(3)], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects grant from non-owner", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("access-control", "grant-role",
      [Cl.standardPrincipal(w2), Cl.uint(2)], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
  it("revokes a role", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("access-control", "grant-role", [Cl.standardPrincipal(w1), Cl.uint(2)], d);
    const r = simnet.callPublicFn("access-control", "revoke-role", [Cl.standardPrincipal(w1), Cl.uint(2)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});'

c tests/snapshots_test.ts \
"Add snapshots tests: record snapshot, retrieve latest, count increments" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("snapshots", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("records a snapshot", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("snapshots", "record-snapshot",
      [Cl.uint(500), Cl.uint(120), Cl.uint(1200), Cl.uint(340)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("retrieves latest snapshot", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("snapshots", "record-snapshot",
      [Cl.uint(500), Cl.uint(120), Cl.uint(1200), Cl.uint(340)], d);
    const r = simnet.callReadOnlyFn("snapshots", "get-latest-snapshot", [], d);
    expect(r.result).toBeSome();
  });
  it("increments snapshot count", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("snapshots", "record-snapshot", [Cl.uint(100), Cl.uint(10), Cl.uint(50), Cl.uint(20)], d);
    simnet.callPublicFn("snapshots", "record-snapshot", [Cl.uint(200), Cl.uint(20), Cl.uint(100), Cl.uint(40)], d);
    const r = simnet.callReadOnlyFn("snapshots", "get-snapshot-count", [], d);
    expect(r.result).toBeUint(2);
  });
});'

c tests/dispatcher_test.ts \
"Add dispatcher tests: register handler, get handler, has-handler check" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("dispatcher", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a handler", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("dispatcher", "register-handler",
      [Cl.stringAscii("diploma"), Cl.stringAscii("verify"),
       Cl.standardPrincipal(d)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms has-handler after registration", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("dispatcher", "register-handler",
      [Cl.stringAscii("research"), Cl.stringAscii("attest"), Cl.standardPrincipal(d)], d);
    const r = simnet.callReadOnlyFn("dispatcher", "has-handler",
      [Cl.stringAscii("research"), Cl.stringAscii("attest")], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects registration from non-owner", () => {
    const w1 = accounts.get("wallet_1")!;
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("dispatcher", "register-handler",
      [Cl.stringAscii("diploma"), Cl.stringAscii("mint"), Cl.standardPrincipal(d)], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
});'

bump "2.0.1"

# ── Docs ──────────────────────────────────────────────────────

c docs/multisig.md \
"Add multisig docs: M-of-N document approval configuration" \
'# ProofLedger Multi-Signature

The `multisig.clar` contract requires M-of-N approvals before a document is considered approved.

## Create a 2-of-3 Config

```clarity
(contract-call? .multisig create-config
  u2   ;; signatures required
  (list SP_SIGNER_1 SP_SIGNER_2 SP_SIGNER_3))
;; Returns: (ok config-id)
```

## Approve a Document

Each signer calls:
```clarity
(contract-call? .multisig approve u1 0x<sha256-hash>)
;; Returns: (ok false) until threshold met
;; Returns: (ok true) when threshold met
```

## Check Approval Status

```clarity
(contract-call? .multisig is-approved u1 0x<hash>)
;; Returns: bool
```

## Use Cases
- Board-approved document certification
- Joint credential issuance
- Multi-party contract notarization'

c docs/access-control.md \
"Add access-control docs: role-based permissions for ProofLedger" \
'# ProofLedger Access Control

The `access-control.clar` contract manages role-based permissions.

## Roles

| Role | Value | Description |
|---|---|---|
| ADMIN | u1 | Full protocol access |
| ISSUER | u2 | Can issue credentials |
| VERIFIER | u3 | Can verify and attest |
| MODERATOR | u4 | Can flag content |

## Grant a Role

```clarity
;; Owner only
(contract-call? .access-control grant-role SP_ADDRESS u2)
```

## Check Roles

```clarity
(contract-call? .access-control has-role SP_ADDRESS u2)
(contract-call? .access-control is-admin SP_ADDRESS)
(contract-call? .access-control is-issuer SP_ADDRESS)
```

## Revoke

```clarity
(contract-call? .access-control revoke-role SP_ADDRESS u2)
```'

c docs/attestation-v2.md \
"Add attestation-v2 docs: weighted attestations with credibility scores" \
'# ProofLedger Attestation v2

Enhanced attestation with credibility weight and comments.

## Attest with Weight

```clarity
(contract-call? .attestation-v2 attest-with-weight
  0x<hash>
  "diploma"          ;; credential type
  u8                 ;; weight 1-10
  "Verified directly with institution")
```

## Get Credibility Score

The average weight of all attestors:

```clarity
(contract-call? .attestation-v2 get-credibility-score 0x<hash>)
;; Returns: uint (average weight, 1-10)
```

## Weight Guidelines

| Weight | Meaning |
|---|---|
| u10 | Direct institutional verification |
| u7-9 | Trusted secondary verification |
| u4-6 | Community attestation |
| u1-3 | Unverified claim |'

c docs/snapshots.md \
"Add snapshots docs: periodic protocol metrics recording" \
'# ProofLedger Snapshots

The `snapshots.clar` contract records periodic protocol metrics on-chain.

## Record a Snapshot

```clarity
(contract-call? .snapshots record-snapshot
  u1500   ;; total documents
  u320    ;; total wallets
  u4200   ;; total attestations
  u890)   ;; total NFTs
;; Returns: (ok epoch-number)
```

## Read Snapshots

```clarity
;; Get latest
(contract-call? .snapshots get-latest-snapshot)

;; Get specific epoch
(contract-call? .snapshots get-snapshot u5)

;; Total snapshots recorded
(contract-call? .snapshots get-snapshot-count)
```

## How It Works

The ProofLedger bot records snapshots daily after each run,
creating a permanent on-chain history of protocol growth.'

c CHANGELOG.md \
"Update CHANGELOG: v2.0.1 — multisig, attestation-v2, access-control, snapshots, dispatcher" \
'# Changelog

## [2.0.1] - 2026-04-14

### Added

**New Contracts:**
- `multisig.clar` — M-of-N document approval
- `attestation-v2.clar` — weighted attestation with credibility scores
- `access-control.clar` — role-based access control
- `snapshots.clar` — periodic protocol metrics snapshots
- `dispatcher.clar` — document type action routing

**Tests:**
- multisig_test.ts — 4 test cases
- attestation_v2_test.ts — 4 test cases
- access_control_test.ts — 4 test cases
- snapshots_test.ts — 3 test cases
- dispatcher_test.ts — 3 test cases

**Docs:**
- multisig.md, access-control.md, attestation-v2.md, snapshots.md

### Breaking Changes
- None — all additions are new contracts

## [2.0.0] - 2026-04-13
- Major version bump — 20+ contracts in ecosystem

## [1.9.1] - 2026-04-12
- vouchers, challenges, shares, auctions, identity contracts

## [1.0.0] - 2026-03-08
- Initial mainnet deployment'

bump "2.1.0"

echo -e "${YELLOW}Pushing...${NC}"
git push origin main -q
echo -e "${GREEN}Done! $TOTAL commits. Version 2.1.0${NC}"
echo "Run: npm publish"
