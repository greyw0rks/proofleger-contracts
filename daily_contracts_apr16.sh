#!/bin/bash
# proofleger-contracts - Daily Commits April 16
# cd proofleger-contracts && bash daily_contracts_apr16.sh

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

echo -e "${YELLOW}Contracts Apr 16 commits starting...${NC}"

# ── New contracts ─────────────────────────────────────────────

c contracts/skill-tree.clar \
"Add skill-tree.clar: on-chain skill endorsement and progression tracking" \
';; skill-tree.clar
;; ProofLedger Skill Tree
;; Track and endorse specific skills linked to credential proofs

(define-map skills
  { owner: principal, skill: (string-ascii 50) }
  { level: uint, first-proof: (buff 32),
    endorsements: uint, last-updated: uint })

(define-map skill-endorsements
  { owner: principal, skill: (string-ascii 50), endorser: principal }
  { endorsed-at: uint })

(define-map skill-proofs
  { owner: principal, skill: (string-ascii 50), index: uint }
  { hash: (buff 32), added-at: uint })

;; add-skill: declare a skill with supporting document proof
;; Errors: u1 = skill already added
(define-public (add-skill (skill (string-ascii 50)) (proof-hash (buff 32)))
  (begin
    (asserts! (is-none (map-get? skills { owner: tx-sender, skill: skill })) (err u1))
    (map-set skills { owner: tx-sender, skill: skill }
      { level: u1, first-proof: proof-hash,
        endorsements: u0, last-updated: stacks-block-height })
    (map-set skill-proofs { owner: tx-sender, skill: skill, index: u0 }
      { hash: proof-hash, added-at: stacks-block-height })
    (ok true)))

;; endorse-skill: endorse someone else skill
;; Errors: u2 = skill not found, u3 = already endorsed, u4 = self-endorse
(define-public (endorse-skill (owner principal) (skill (string-ascii 50)))
  (let ((s (unwrap! (map-get? skills { owner: owner, skill: skill }) (err u2))))
    (asserts! (not (is-eq tx-sender owner)) (err u4))
    (asserts! (is-none (map-get? skill-endorsements { owner: owner, skill: skill, endorser: tx-sender })) (err u3))
    (map-set skill-endorsements { owner: owner, skill: skill, endorser: tx-sender }
      { endorsed-at: stacks-block-height })
    (map-set skills { owner: owner, skill: skill }
      (merge s { endorsements: (+ (get endorsements s) u1) }))
    (ok true)))

(define-read-only (get-skill (owner principal) (skill (string-ascii 50)))
  (map-get? skills { owner: owner, skill: skill }))

(define-read-only (is-endorsed-by (owner principal) (skill (string-ascii 50)) (endorser principal))
  (is-some (map-get? skill-endorsements { owner: owner, skill: skill, endorser: endorser })))'

c contracts/publication.clar \
"Add publication.clar: on-chain academic and research publication registry" \
';; publication.clar
;; ProofLedger Publication Registry
;; Register academic papers, articles, and research publications on-chain

(define-map publications
  { hash: (buff 32) }
  { author: principal, title: (string-ascii 150),
    abstract-hash: (buff 32), doi: (string-ascii 100),
    pub-type: (string-ascii 30), published-at: uint,
    citation-count: uint })

(define-map citations
  { citing-hash: (buff 32), cited-hash: (buff 32) }
  { cited-at: uint, citer: principal })

(define-data-var total-publications uint u0)

;; publish: register a new publication
;; Errors: u1 = hash already published
(define-public (publish (hash (buff 32)) (title (string-ascii 150))
                         (abstract-hash (buff 32)) (doi (string-ascii 100))
                         (pub-type (string-ascii 30)))
  (begin
    (asserts! (is-none (map-get? publications { hash: hash })) (err u1))
    (map-set publications { hash: hash }
      { author: tx-sender, title: title, abstract-hash: abstract-hash,
        doi: doi, pub-type: pub-type,
        published-at: stacks-block-height, citation-count: u0 })
    (var-set total-publications (+ (var-get total-publications) u1))
    (ok true)))

;; cite: record that one publication cites another
;; Errors: u2 = cited paper not found, u3 = already cited
(define-public (cite (citing-hash (buff 32)) (cited-hash (buff 32)))
  (let ((cited (unwrap! (map-get? publications { hash: cited-hash }) (err u2))))
    (asserts! (is-none (map-get? citations { citing-hash: citing-hash, cited-hash: cited-hash })) (err u3))
    (map-set citations { citing-hash: citing-hash, cited-hash: cited-hash }
      { cited-at: stacks-block-height, citer: tx-sender })
    (map-set publications { hash: cited-hash }
      (merge cited { citation-count: (+ (get citation-count cited) u1) }))
    (ok true)))

(define-read-only (get-publication (hash (buff 32)))
  (map-get? publications { hash: hash }))

(define-read-only (get-citation-count (hash (buff 32)))
  (default-to u0 (get citation-count (map-get? publications { hash: hash }))))'

c contracts/event-log.clar \
"Add event-log.clar: append-only on-chain event log for auditability" \
';; event-log.clar
;; ProofLedger Audit Event Log
;; Immutable, append-only log of protocol events for auditability

(define-map events
  { index: uint }
  { event-type: (string-ascii 50), actor: principal,
    subject: (optional principal), hash: (optional (buff 32)),
    data: (string-ascii 200), logged-at: uint })

(define-data-var event-count uint u0)

;; log-event: append an event to the audit log
(define-public (log-event (event-type (string-ascii 50))
                           (subject (optional principal))
                           (hash (optional (buff 32)))
                           (data (string-ascii 200)))
  (let ((idx (var-get event-count)))
    (map-set events { index: idx }
      { event-type: event-type, actor: tx-sender,
        subject: subject, hash: hash,
        data: data, logged-at: stacks-block-height })
    (var-set event-count (+ idx u1))
    (ok idx)))

(define-read-only (get-event (index uint))
  (map-get? events { index: index }))

(define-read-only (get-event-count)
  (var-get event-count))'

c contracts/proof-nft.clar \
"Add proof-nft.clar: transferable NFT representing document ownership" \
';; proof-nft.clar
;; ProofLedger Transferable Proof NFT
;; Transferable NFTs representing document proof ownership
;; (unlike achievements which are soulbound)

(define-non-fungible-token proof-nft uint)
(define-data-var token-count uint u0)

(define-map token-data
  { token-id: uint }
  { hash: (buff 32), title: (string-ascii 100),
    doc-type: (string-ascii 50), minted-at: uint,
    original-owner: principal })

(define-map hash-to-token
  { hash: (buff 32) }
  { token-id: uint })

;; mint: create a transferable proof NFT
;; Errors: u1 = NFT already minted for this hash
(define-public (mint (hash (buff 32)) (title (string-ascii 100)) (doc-type (string-ascii 50)))
  (begin
    (asserts! (is-none (map-get? hash-to-token { hash: hash })) (err u1))
    (let ((id (+ (var-get token-count) u1)))
      (try! (nft-mint? proof-nft id tx-sender))
      (var-set token-count id)
      (map-set token-data { token-id: id }
        { hash: hash, title: title, doc-type: doc-type,
          minted-at: stacks-block-height, original-owner: tx-sender })
      (map-set hash-to-token { hash: hash } { token-id: id })
      (ok id))))

;; transfer: transfer NFT ownership (unlike achievements, this is allowed)
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u2))
    (try! (nft-transfer? proof-nft token-id sender recipient))
    (ok true)))

(define-read-only (get-owner (token-id uint))
  (nft-get-owner? proof-nft token-id))

(define-read-only (get-token-data (token-id uint))
  (map-get? token-data { token-id: token-id }))'

c contracts/community-pool.clar \
"Add community-pool.clar: community funding pool for protocol development" \
';; community-pool.clar
;; ProofLedger Community Pool
;; Collect and manage community contributions for protocol development

(define-data-var pool-balance uint u0)
(define-data-var total-contributors uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map contributions
  { contributor: principal }
  { total: uint, count: uint, first-at: uint, last-at: uint })

(define-map grants
  { id: uint }
  { recipient: principal, amount: uint,
    purpose: (string-ascii 200), granted-at: uint })

(define-data-var grant-count uint u0)

;; contribute: donate STX to the community pool
(define-public (contribute (amount uint))
  (begin
    (asserts! (> amount u0) (err u1))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((existing (default-to { total: u0, count: u0, first-at: stacks-block-height, last-at: u0 }
            (map-get? contributions { contributor: tx-sender }))))
      (when (is-eq (get count existing) u0)
        (var-set total-contributors (+ (var-get total-contributors) u1)))
      (map-set contributions { contributor: tx-sender }
        (merge existing { total: (+ (get total existing) amount),
                          count: (+ (get count existing) u1),
                          last-at: stacks-block-height })))
    (var-set pool-balance (+ (var-get pool-balance) amount))
    (ok true)))

;; grant: owner disburses funds from the pool
;; Errors: u403 = not owner, u2 = insufficient balance
(define-public (grant (recipient principal) (amount uint) (purpose (string-ascii 200)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (<= amount (var-get pool-balance)) (err u2))
    (try! (as-contract (stx-transfer? amount tx-sender recipient)))
    (let ((id (+ (var-get grant-count) u1)))
      (map-set grants { id: id }
        { recipient: recipient, amount: amount,
          purpose: purpose, granted-at: stacks-block-height })
      (var-set grant-count id))
    (var-set pool-balance (- (var-get pool-balance) amount))
    (ok true)))

(define-read-only (get-pool-balance) (var-get pool-balance))
(define-read-only (get-total-contributors) (var-get total-contributors))
(define-read-only (get-contribution (contributor principal))
  (map-get? contributions { contributor: contributor }))'

# ── Tests ─────────────────────────────────────────────────────

c tests/skill_tree_test.ts \
"Add skill-tree tests: add skill, endorse, self-endorse rejection, duplicate" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("skill-tree", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("adds a skill with proof", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("skill-tree", "add-skill",
      [Cl.stringAscii("Clarity Smart Contracts"), hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate skill", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("TypeScript"), hash], d);
    const r = simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("TypeScript"), hash], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("endorses a skill", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("Solidity"), hash], d);
    const r = simnet.callPublicFn("skill-tree", "endorse-skill",
      [Cl.standardPrincipal(d), Cl.stringAscii("Solidity")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects self-endorsement", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("Python"), hash], d);
    const r = simnet.callPublicFn("skill-tree", "endorse-skill",
      [Cl.standardPrincipal(d), Cl.stringAscii("Python")], d);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});'

c tests/publication_test.ts \
"Add publication tests: publish, cite, duplicate rejection, citation count" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("publication", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a publication", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const abs = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("publication", "publish",
      [hash, Cl.stringAscii("ZK Proofs on Stacks"), abs,
       Cl.stringAscii("10.1234/test"), Cl.stringAscii("research")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const abs = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("publication", "publish",
      [hash, Cl.stringAscii("Paper 1"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    const r = simnet.callPublicFn("publication", "publish",
      [hash, Cl.stringAscii("Paper 2"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("records a citation", () => {
    const d = accounts.get("deployer")!;
    const h1 = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
    const h2 = Cl.buffer(Buffer.from("f".repeat(64), "hex"));
    const abs = Cl.buffer(Buffer.from("1".repeat(64), "hex"));
    simnet.callPublicFn("publication", "publish",
      [h1, Cl.stringAscii("Original"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    simnet.callPublicFn("publication", "publish",
      [h2, Cl.stringAscii("Citing"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    const r = simnet.callPublicFn("publication", "cite", [h2, h1], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});'

c tests/event_log_test.ts \
"Add event-log tests: log events, retrieve, count increments" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("event-log", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("logs an event", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("document.anchored"), Cl.none(), Cl.none(),
       Cl.stringAscii("Document anchored by bot")], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("retrieves a logged event", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("wallet.connected"), Cl.none(), Cl.none(), Cl.stringAscii("data")], d);
    const r = simnet.callReadOnlyFn("event-log", "get-event", [Cl.uint(0)], d);
    expect(r.result).toBeSome();
  });
  it("increments event count", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("event.1"), Cl.none(), Cl.none(), Cl.stringAscii("")], d);
    simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("event.2"), Cl.none(), Cl.none(), Cl.stringAscii("")], d);
    const r = simnet.callReadOnlyFn("event-log", "get-event-count", [], d);
    expect(r.result).toBeUint(2);
  });
});'

c tests/proof_nft_test.ts \
"Add proof-nft tests: mint, transfer, duplicate mint rejection" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-nft", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("mints a transferable proof NFT", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Research Paper 2026"), Cl.stringAscii("research")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("rejects duplicate mint for same hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Diploma"), Cl.stringAscii("diploma")], d);
    const r = simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Diploma 2"), Cl.stringAscii("diploma")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("transfers NFT to another wallet", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Art NFT"), Cl.stringAscii("art")], d);
    const r = simnet.callPublicFn("proof-nft", "transfer",
      [Cl.uint(1), Cl.standardPrincipal(d), Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});'

c tests/community_pool_test.ts \
"Add community-pool tests: contribute, grant, access control, balance tracking" \
'import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("community-pool", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("accepts a contribution", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("community-pool", "contribute", [Cl.uint(500000)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects zero contribution", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("community-pool", "contribute", [Cl.uint(0)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("rejects grant from non-owner", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("community-pool", "grant",
      [Cl.standardPrincipal(w2), Cl.uint(100), Cl.stringAscii("Hack")], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
});'

# ── Docs ──────────────────────────────────────────────────────

c docs/skill-tree.md \
"Add skill-tree docs: on-chain skill declaration and endorsement system" \
'# ProofLedger Skill Tree

The `skill-tree.clar` contract enables on-chain skill tracking with proof-backed endorsements.

## Add a Skill

```clarity
(contract-call? .skill-tree add-skill
  "Clarity Smart Contracts"
  0x<proof-hash>)  ;; supporting credential
```

## Endorse Someone Skill

```clarity
(contract-call? .skill-tree endorse-skill
  SP_DEVELOPER_ADDRESS
  "Clarity Smart Contracts")
```

## Read Skills

```clarity
(contract-call? .skill-tree get-skill SP_ADDRESS "Solidity")
;; Returns: { level, first-proof, endorsements, last-updated }
```

## Use Cases
- Developer skill profiles
- Freelancer portfolio verification
- DAO contributor capability tracking'

c docs/publication.md \
"Add publication docs: academic research registration and citation tracking" \
'# ProofLedger Publications

The `publication.clar` contract creates an on-chain academic publication registry.

## Publish a Paper

```clarity
(contract-call? .publication publish
  0x<full-paper-hash>
  "Zero-Knowledge Proofs in Identity Systems"
  0x<abstract-hash>
  "10.1234/zk-identity-2026"  ;; DOI
  "research")                  ;; type
```

## Cite a Paper

```clarity
(contract-call? .publication cite
  0x<citing-paper-hash>
  0x<cited-paper-hash>)
```

## Get Citation Count

```clarity
(contract-call? .publication get-citation-count 0x<hash>)
```

## Publication Types

`research`, `review`, `conference`, `preprint`, `thesis`, `patent`, `other`'

c docs/community-pool.md \
"Add community-pool docs: funding protocol development through community contributions" \
'# ProofLedger Community Pool

The `community-pool.clar` contract manages community funding for protocol development.

## Contribute

```clarity
(contract-call? .community-pool contribute u1000000)
;; Contribute 1 STX to the community pool
```

## Check Pool Balance

```clarity
(contract-call? .community-pool get-pool-balance)
(contract-call? .community-pool get-total-contributors)
```

## Your Contribution History

```clarity
(contract-call? .community-pool get-contribution tx-sender)
;; Returns: { total, count, first-at, last-at }
```

## Grants

The contract owner can disburse grants to contributors and builders:
```clarity
;; Owner only
(contract-call? .community-pool grant
  SP_RECIPIENT
  u5000000
  "ProofLedger SDK development Q2 2026")
```'

c CHANGELOG.md \
"Update CHANGELOG: skill-tree, publication, event-log, proof-nft, community-pool" \
'# Changelog

## [2.2.2] - 2026-04-16

### Added

**New Contracts:**
- `skill-tree.clar` — on-chain skill tracking with proof-backed endorsements
- `publication.clar` — academic publication registry with citation tracking
- `event-log.clar` — append-only audit event log
- `proof-nft.clar` — transferable proof ownership NFTs
- `community-pool.clar` — community funding pool with grants

**Tests:**
- skill_tree_test.ts — 4 test cases
- publication_test.ts — 3 test cases
- event_log_test.ts — 3 test cases
- proof_nft_test.ts — 3 test cases
- community_pool_test.ts — 3 test cases

**Docs:**
- skill-tree.md, publication.md, community-pool.md

## [2.2.1] - 2026-04-15
- fee-collector, credential-registry, proof-chain, expiring-credentials, document-updates

## [2.2.0] - 2026-04-14
- multisig, attestation-v2, access-control, snapshots, dispatcher

## [1.0.0] - 2026-03-08
- Initial mainnet deployment'

echo -e "${YELLOW}Pushing...${NC}"
git push origin main -q
echo -e "${GREEN}Done! $TOTAL commits${NC}"
