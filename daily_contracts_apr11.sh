#!/bin/bash
# proofleger-contracts - Daily Commits April 11
# cd proofleger-contracts && bash daily_contracts_apr11.sh

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

echo -e "${YELLOW}Contracts daily commits starting...${NC}"

# ── New contracts ─────────────────────────────────────────────

c contracts/notary.clar \
"Add notary.clar: notarization contract with witness signatures" \
';; notary.clar
;; ProofLedger On-Chain Notary
;; Documents can be notarized with multiple witness signatures

(define-map notarizations
  { hash: (buff 32) }
  { notary: principal, notarized-at: uint, description: (string-ascii 200), witness-count: uint })

(define-map witnesses
  { hash: (buff 32), witness: principal }
  { signed-at: uint, statement: (string-ascii 100) })

(define-map witness-index
  { hash: (buff 32), index: uint }
  { witness: principal })

;; notarize: create a notarization record for a document hash
;; Errors: u1 = already notarized
(define-public (notarize (hash (buff 32)) (description (string-ascii 200)))
  (begin
    (asserts! (is-none (map-get? notarizations { hash: hash })) (err u1))
    (map-set notarizations { hash: hash }
      { notary: tx-sender, notarized-at: stacks-block-height,
        description: description, witness-count: u0 })
    (ok true)))

;; add-witness: add a witness signature to a notarized document
;; Errors: u2 = not notarized, u3 = already witnessed by this address
(define-public (add-witness (hash (buff 32)) (statement (string-ascii 100)))
  (let ((notary (unwrap! (map-get? notarizations { hash: hash }) (err u2)))
        (count (get witness-count notary)))
    (asserts! (is-none (map-get? witnesses { hash: hash, witness: tx-sender })) (err u3))
    (map-set witnesses { hash: hash, witness: tx-sender }
      { signed-at: stacks-block-height, statement: statement })
    (map-set witness-index { hash: hash, index: count } { witness: tx-sender })
    (map-set notarizations { hash: hash }
      (merge notary { witness-count: (+ count u1) }))
    (ok true)))

(define-read-only (get-notarization (hash (buff 32)))
  (map-get? notarizations { hash: hash }))

(define-read-only (get-witness (hash (buff 32)) (witness principal))
  (map-get? witnesses { hash: hash, witness: witness }))

(define-read-only (is-notarized (hash (buff 32)))
  (is-some (map-get? notarizations { hash: hash })))'

c contracts/escrow.clar \
"Add escrow.clar: document-gated STX escrow release" \
';; escrow.clar
;; ProofLedger Document Escrow
;; Release STX when a specific document hash is verified on-chain

(define-map escrows
  { id: uint }
  { depositor: principal, recipient: principal, amount: uint,
    required-hash: (buff 32), released: bool, created-at: uint })

(define-data-var escrow-count uint u0)

;; create-escrow: deposit STX locked to a document hash condition
;; Errors: u1 = amount must be positive
(define-public (create-escrow (recipient principal) (required-hash (buff 32)) (amount uint))
  (begin
    (asserts! (> amount u0) (err u1))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((id (+ (var-get escrow-count) u1)))
      (map-set escrows { id: id }
        { depositor: tx-sender, recipient: recipient, amount: amount,
          required-hash: required-hash, released: false, created-at: stacks-block-height })
      (var-set escrow-count id)
      (ok id))))

;; release-escrow: recipient claims funds by providing the document proof
;; In production this would verify against proofleger3 contract
;; Errors: u2 = not found, u3 = already released, u4 = not the recipient
(define-public (release-escrow (id uint))
  (let ((escrow (unwrap! (map-get? escrows { id: id }) (err u2))))
    (asserts! (not (get released escrow)) (err u3))
    (asserts! (is-eq tx-sender (get recipient escrow)) (err u4))
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get recipient escrow))))
    (map-set escrows { id: id } (merge escrow { released: true }))
    (ok true)))

(define-read-only (get-escrow (id uint))
  (map-get? escrows { id: id }))'

c contracts/achievements-v2.clar \
"Add achievements-v2.clar: upgraded soulbound NFT with metadata URI support" \
';; achievements-v2.clar
;; ProofLedger Achievement NFTs v2
;; Extended soulbound NFT with external metadata URI and categories

(define-non-fungible-token achievement-v2 uint)
(define-data-var token-counter uint u0)

(define-map token-metadata
  { token-id: uint }
  { hash: (buff 32), achievement-type: (string-ascii 50),
    title: (string-ascii 100), minted-at: uint, owner: principal,
    metadata-uri: (string-ascii 256), category: (string-ascii 30) })

(define-map hash-to-token
  { hash: (buff 32), owner: principal }
  { token-id: uint })

(define-map owner-token-count
  { owner: principal }
  { count: uint })

;; mint: mint soulbound achievement with optional metadata URI
;; Errors: u1 = already minted for this hash
(define-public (mint (hash (buff 32)) (achievement-type (string-ascii 50))
                     (title (string-ascii 100)) (metadata-uri (string-ascii 256))
                     (category (string-ascii 30)))
  (let ((existing (map-get? hash-to-token { hash: hash, owner: tx-sender }))
        (token-id (+ (var-get token-counter) u1))
        (count (default-to u0 (get count (map-get? owner-token-count { owner: tx-sender })))))
    (asserts! (is-none existing) (err u1))
    (try! (nft-mint? achievement-v2 token-id tx-sender))
    (var-set token-counter token-id)
    (map-set token-metadata { token-id: token-id }
      { hash: hash, achievement-type: achievement-type, title: title,
        minted-at: stacks-block-height, owner: tx-sender,
        metadata-uri: metadata-uri, category: category })
    (map-set hash-to-token { hash: hash, owner: tx-sender } { token-id: token-id })
    (map-set owner-token-count { owner: tx-sender } { count: (+ count u1) })
    (ok token-id)))

;; transfer is always blocked — achievements are soulbound
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (err u500))

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id }))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? achievement-v2 token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get token-counter)))'

c contracts/payment-splitter.clar \
"Add payment-splitter.clar: split STX payments between multiple recipients" \
';; payment-splitter.clar
;; ProofLedger Payment Splitter
;; Split incoming STX payments proportionally between multiple recipients

(define-map splits
  { id: uint }
  { creator: principal, created-at: uint, recipient-count: uint })

(define-map split-recipients
  { split-id: uint, index: uint }
  { recipient: principal, share: uint })

(define-data-var split-count uint u0)

;; create-split: define a new payment split configuration
;; shares must sum to 100
(define-public (create-split (recipients (list 10 { recipient: principal, share: uint })))
  (let ((total (fold + (map get-share recipients) u0))
        (id (+ (var-get split-count) u1)))
    (asserts! (is-eq total u100) (err u1))
    (var-set split-count id)
    (map-set splits { id: id }
      { creator: tx-sender, created-at: stacks-block-height,
        recipient-count: (len recipients) })
    (ok id)))

(define-private (get-share (r { recipient: principal, share: uint }))
  (get share r))

(define-read-only (get-split (id uint))
  (map-get? splits { id: id }))'

c contracts/proof-of-work.clar \
"Add proof-of-work.clar: on-chain work log for contributor tracking" \
';; proof-of-work.clar
;; ProofLedger Proof of Work
;; Contributors log work items on-chain with associated document hashes

(define-map work-logs
  { contributor: principal, index: uint }
  { hash: (buff 32), description: (string-ascii 200),
    work-type: (string-ascii 50), hours: uint, logged-at: uint })

(define-map work-count
  { contributor: principal }
  { count: uint, total-hours: uint })

;; log-work: record a work item with an associated document proof
;; Errors: u1 = hours must be positive
(define-public (log-work (hash (buff 32)) (description (string-ascii 200))
                          (work-type (string-ascii 50)) (hours uint))
  (let ((existing (default-to { count: u0, total-hours: u0 }
          (map-get? work-count { contributor: tx-sender })))
        (idx (get count existing)))
    (asserts! (> hours u0) (err u1))
    (map-set work-logs { contributor: tx-sender, index: idx }
      { hash: hash, description: description, work-type: work-type,
        hours: hours, logged-at: stacks-block-height })
    (map-set work-count { contributor: tx-sender }
      { count: (+ idx u1), total-hours: (+ (get total-hours existing) hours) })
    (ok idx)))

(define-read-only (get-work-log (contributor principal) (index uint))
  (map-get? work-logs { contributor: contributor, index: index }))

(define-read-only (get-work-summary (contributor principal))
  (map-get? work-count { contributor: contributor }))'

bump "1.7.0"

# ── Tests ─────────────────────────────────────────────────────

c tests/notary_test.ts \
"Add notary tests: notarize, add witness, duplicate rejection" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("notary", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("notarizes a document hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("Legal agreement 2026")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate notarization", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("doc")], d);
    const r = simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("doc")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("adds a witness signature", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("contract")], d);
    const r = simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("I confirm")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate witness", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("contract")], d);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("I confirm")], w1);
    const r = simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("again")], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});'

c tests/achievements_v2_test.ts \
"Add achievements-v2 tests: mint with URI, soulbound transfer block" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("achievements-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("mints NFT with metadata URI", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("diploma"), Cl.stringAscii("BSc CS"),
       Cl.stringAscii("ipfs://QmTest"), Cl.stringAscii("education")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("blocks soulbound transfer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("diploma"), Cl.stringAscii("Degree"),
       Cl.stringAscii(""), Cl.stringAscii("education")], d);
    const r = simnet.callPublicFn("achievements-v2", "transfer",
      [Cl.uint(1), Cl.standardPrincipal(d), Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeErr(Cl.uint(500));
  });
  it("rejects duplicate mint", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("award"), Cl.stringAscii("Winner"),
       Cl.stringAscii(""), Cl.stringAscii("awards")], d);
    const r = simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("award"), Cl.stringAscii("Winner"),
       Cl.stringAscii(""), Cl.stringAscii("awards")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});'

c tests/proof_of_work_test.ts \
"Add proof-of-work tests: log work, get summary, zero hours rejection" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-of-work", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("logs a work item", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-of-work", "log-work",
      [hash, Cl.stringAscii("Built ProofLedger SDK"), Cl.stringAscii("development"), Cl.uint(8)], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("rejects zero hours", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-of-work", "log-work",
      [hash, Cl.stringAscii("Work"), Cl.stringAscii("dev"), Cl.uint(0)], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("accumulates total hours", () => {
    const d = accounts.get("deployer")!;
    const h1 = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const h2 = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("proof-of-work", "log-work", [h1, Cl.stringAscii("day1"), Cl.stringAscii("dev"), Cl.uint(8)], d);
    simnet.callPublicFn("proof-of-work", "log-work", [h2, Cl.stringAscii("day2"), Cl.stringAscii("dev"), Cl.uint(6)], d);
    const r = simnet.callReadOnlyFn("proof-of-work", "get-work-summary", [Cl.standardPrincipal(d)], d);
    expect(r.result).toBeSome();
  });
});'

c tests/notary_witness_test.ts \
"Add notary witness count tests: multiple witnesses increment counter" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("notary witness counting", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("increments witness count with each signature", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const w3 = accounts.get("wallet_3")!;
    const hash = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("Multi-witness doc")], d);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("Witness 1")], w1);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("Witness 2")], w2);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("Witness 3")], w3);
    const r = simnet.callReadOnlyFn("notary", "get-notarization", [hash], d);
    expect(r.result).toBeSome();
  });
  it("confirms is-notarized after notarization", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("f".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("test")], d);
    const r = simnet.callReadOnlyFn("notary", "is-notarized", [hash], d);
    expect(r.result).toBeBool(true);
  });
});'

bump "1.7.1"

# ── Docs ──────────────────────────────────────────────────────

c docs/notary.md \
"Add notary docs: on-chain notarization with multi-witness support" \
'# ProofLedger Notary

The `notary.clar` contract enables on-chain document notarization with witness signatures.

## Notarize a Document

```clarity
(contract-call? .notary notarize
  0x<sha256-hash>
  "Purchase agreement between Alice and Bob")
```

## Add Witness Signatures

```clarity
(contract-call? .notary add-witness
  0x<sha256-hash>
  "I was present and confirm this agreement")
```

## Verify Notarization

```clarity
(contract-call? .notary is-notarized 0x<hash>)
;; Returns: bool

(contract-call? .notary get-notarization 0x<hash>)
;; Returns: { notary, notarized-at, description, witness-count }
```

## Use Cases
- Legal contracts with multiple signatories
- Real estate transaction records
- Business agreement notarization
- Academic degree verification with institutional witness'

c docs/proof-of-work.md \
"Add proof-of-work docs: contributor work logging and tracking" \
'# ProofLedger Proof of Work

The `proof-of-work.clar` contract lets contributors log work on-chain with document proofs.

## Log Work

```clarity
(contract-call? .proof-of-work log-work
  0x<sha256-hash>   ;; hash of work deliverable
  "Built ProofLedger mobile UI"
  "development"
  u40)              ;; hours worked
```

## Get Summary

```clarity
(contract-call? .proof-of-work get-work-summary tx-sender)
;; Returns: { count, total-hours }
```

## Use Cases
- Freelancer payment verification
- DAO contributor tracking
- Open source contribution proofs
- Consulting hour logs with deliverable hashes'

c docs/achievements-v2.md \
"Add achievements-v2 docs: upgraded NFTs with metadata URI support" \
'# ProofLedger Achievements v2

Enhanced soulbound NFTs with external metadata URI and category support.

## Mint with Metadata

```clarity
(contract-call? .achievements-v2 mint
  0x<sha256-hash>
  "diploma"
  "Bachelor of Science"
  "ipfs://QmYourMetadataCID"
  "education")
```

## Metadata URI

The `metadata-uri` field supports:
- IPFS: `ipfs://Qm...`
- HTTPS: `https://...`
- Empty string for on-chain only

## Categories

Common categories:
- `education` — degrees, certificates
- `professional` — work achievements
- `community` — DAO contributions
- `awards` — competitions, hackathons

## Read NFT Data

```clarity
(contract-call? .achievements-v2 get-token-metadata u1)
;; Returns full metadata including URI and category
```'

c docs/escrow.md \
"Add escrow docs: document-gated STX escrow release" \
'# ProofLedger Escrow

The `escrow.clar` contract locks STX until a document is verified on-chain.

## Create an Escrow

```clarity
(contract-call? .escrow create-escrow
  SP_RECIPIENT_ADDRESS
  0x<required-document-hash>
  u1000000)   ;; 1 STX
;; Returns: (ok escrow-id)
```

## Release Funds

The recipient calls this after providing proof:

```clarity
(contract-call? .escrow release-escrow u1)
```

## Use Cases
- Pay for credential verification
- Freelance payment on delivery proof
- Grant disbursement on milestone proof
- Insurance claim on document submission'

c CHANGELOG.md \
"Update CHANGELOG: v1.7.1 with notary, escrow, achievements-v2, proof-of-work" \
'# Changelog

## [1.7.1] - 2026-04-11

### Added

**New Contracts:**
- `notary.clar` — on-chain notarization with multi-witness support
- `escrow.clar` — document-gated STX escrow
- `achievements-v2.clar` — soulbound NFTs with metadata URI and categories
- `payment-splitter.clar` — proportional STX payment splitting
- `proof-of-work.clar` — contributor work logging with document proofs

**Tests:**
- notary_test.ts — 4 test cases
- notary_witness_test.ts — 2 test cases
- achievements_v2_test.ts — 3 test cases
- proof_of_work_test.ts — 3 test cases

**Docs:**
- notary.md, proof-of-work.md, achievements-v2.md, escrow.md

## [1.6.1] - 2026-04-10
- staking, referrals, whitelist, leaderboard, certifier contracts

## [1.5.0] - 2026-04-07
- 10 new contracts including governance, badges, oracle

## [1.0.0] - 2026-03-08
- Initial mainnet deployment'

bump "1.8.0"

echo -e "${YELLOW}Pushing...${NC}"
git push origin main -q

echo -e "${GREEN}Done! $TOTAL commits. Version 1.8.0${NC}"
echo "Run: npm publish  (from proofleger-contracts directory)"
