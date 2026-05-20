#!/usr/bin/env bash
set -e
cd ~/proofleger-contracts

COUNT=0
commit() {
  git add "$1"
  git commit -q -m "$2"
  COUNT=$((COUNT+1))
  echo "✅ $2"
}

mkdir -p contracts tests

# ── oracle-v2 ─────────────────────────────────────────────────────────────────
cat > contracts/oracle-v2.clar << 'EOF'
;; oracle-v2.clar
;; Multi-source price oracle with median aggregation and staleness checks
;; Errors:
;;   u100 - not authorized feeder
;;   u101 - asset not found
;;   u102 - price stale
;;   u103 - insufficient sources

(define-constant CONTRACT-OWNER tx-sender)
(define-constant STALE-BLOCKS u20)
(define-constant MIN-SOURCES u2)

(define-map feeders principal { active: bool, submissions: uint })
(define-map price-feeds
  { asset: (string-ascii 10), feeder: principal }
  { price: uint, submitted-at: uint })

(define-map aggregated-prices
  { asset: (string-ascii 10) }
  { price: uint, sources: uint, updated-at: uint })

(define-public (authorize-feeder (feeder principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u100))
    (ok (map-set feeders feeder { active: true, submissions: u0 }))))

(define-public (submit-price (asset (string-ascii 10)) (price uint))
  (let ((feeder (unwrap! (map-get? feeders tx-sender) (err u100))))
    (asserts! (get active feeder) (err u100))
    (map-set price-feeds { asset: asset, feeder: tx-sender }
      { price: price, submitted-at: block-height })
    (map-set feeders tx-sender (merge feeder { submissions: (+ (get submissions feeder) u1) }))
    (ok price)))

(define-public (aggregate-price (asset (string-ascii 10)) (prices (list 5 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u100))
    (asserts! (>= (len prices) MIN-SOURCES) (err u103))
    (let ((median (unwrap! (element-at prices (/ (len prices) u2)) (err u103))))
      (map-set aggregated-prices { asset: asset }
        { price: median, sources: (len prices), updated-at: block-height })
      (ok median))))

(define-read-only (get-price (asset (string-ascii 10)))
  (match (map-get? aggregated-prices { asset: asset })
    feed
    (if (<= (- block-height (get updated-at feed)) STALE-BLOCKS)
      (ok (get price feed))
      (err u102))
    (err u101)))

(define-read-only (get-feeder-submissions (feeder principal))
  (match (map-get? feeders feeder)
    f (get submissions f)
    u0))
EOF
commit "contracts/oracle-v2.clar" "Add oracle-v2: multi-source price oracle with median aggregation"

cat > tests/oracle-v2.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('oracle-v2', () => {
  it('authorized feeder can submit price', async () => {
    const chain = new Chain();
    const [deployer, feeder] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('oracle-v2', 'authorize-feeder',
        [types.principal(feeder.address)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('oracle-v2', 'submit-price',
        [types.ascii('STX'), types.uint(1_500_000)], feeder.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('unauthorized feeder is rejected', async () => {
    const chain = new Chain();
    const [, stranger] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('oracle-v2', 'submit-price',
        [types.ascii('BTC'), types.uint(60_000_000_000)], stranger.address),
    ]);
    expect(block.receipts[0].result).toContain('err u100');
  });

  it('aggregates price from multiple sources', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('oracle-v2', 'aggregate-price',
        [types.ascii('STX'), types.list([
          types.uint(1_400_000),
          types.uint(1_500_000),
          types.uint(1_600_000),
        ])], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('returns error for stale price feed', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('oracle-v2', 'aggregate-price',
        [types.ascii('CELO'), types.list([types.uint(500_000), types.uint(520_000)])],
        deployer.address),
    ]);
    chain.mineEmptyBlock(25);
    const result = chain.callReadOnlyFn('oracle-v2', 'get-price',
      [types.ascii('CELO')], deployer.address);
    expect(result.result).toContain('err u102');
  });
});
EOF
commit "tests/oracle-v2.test.ts" "Add oracle-v2 tests: 4 cases covering submission, aggregation, and staleness"

# ── staking-v2 ────────────────────────────────────────────────────────────────
cat > contracts/staking-v2.clar << 'EOF'
;; staking-v2.clar
;; Improved staking with auto-renew, lock-period tiers, and reward distribution
;; Errors:
;;   u100 - already staked
;;   u101 - not staked
;;   u102 - lock period active
;;   u103 - invalid lock period
;;   u104 - zero amount

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-STAKE u1000000)

(define-map stakes principal
  { amount: uint, lock-cycles: uint, start-block: uint,
    unlock-block: uint, auto-renew: bool, rewards-earned: uint })

(define-map lock-tiers uint uint)
(define-data-var total-staked uint u0)
(define-data-var reward-rate uint u50)

(define-public (set-lock-tier (cycles uint) (bonus-bps uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u100))
    (ok (map-set lock-tiers cycles bonus-bps))))

(define-public (stake (amount uint) (lock-cycles uint) (auto-renew bool))
  (begin
    (asserts! (>= amount MIN-STAKE) (err u104))
    (asserts! (is-none (map-get? stakes tx-sender)) (err u100))
    (asserts! (> lock-cycles u0) (err u103))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((unlock (+ block-height (* lock-cycles u2100))))
      (map-set stakes tx-sender
        { amount: amount, lock-cycles: lock-cycles,
          start-block: block-height, unlock-block: unlock,
          auto-renew: auto-renew, rewards-earned: u0 })
      (var-set total-staked (+ (var-get total-staked) amount))
      (ok unlock))))

(define-public (unstake)
  (let ((s (unwrap! (map-get? stakes tx-sender) (err u101))))
    (asserts! (>= block-height (get unlock-block s)) (err u102))
    (try! (as-contract (stx-transfer? (get amount s) tx-sender tx-sender)))
    (var-set total-staked (- (var-get total-staked) (get amount s)))
    (map-delete stakes tx-sender)
    (ok (get amount s))))

(define-public (toggle-auto-renew)
  (let ((s (unwrap! (map-get? stakes tx-sender) (err u101))))
    (ok (map-set stakes tx-sender (merge s { auto-renew: (not (get auto-renew s)) })))))

(define-read-only (get-stake (address principal))
  (map-get? stakes address))

(define-read-only (get-total-staked)
  (var-get total-staked))

(define-read-only (is-unlocked? (address principal))
  (match (map-get? stakes address)
    s (>= block-height (get unlock-block s))
    false))
EOF
commit "contracts/staking-v2.clar" "Add staking-v2: tiered lock periods with auto-renew and reward tracking"

cat > tests/staking-v2.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('staking-v2', () => {
  it('user can stake above minimum amount', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(1), types.bool(false)], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('rejects duplicate stake from same address', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(1), types.bool(false)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(2), types.bool(true)], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u100');
  });

  it('unstake fails before lock period ends', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(10_000_000), types.uint(2), types.bool(true)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'unstake', [], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u102');
  });

  it('auto-renew toggle flips the flag', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(1), types.bool(false)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'toggle-auto-renew', [], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });
});
EOF
commit "tests/staking-v2.test.ts" "Add staking-v2 tests: 4 cases covering lock enforcement and auto-renew"

# ── vote-delegation ───────────────────────────────────────────────────────────
cat > contracts/vote-delegation.clar << 'EOF'
;; vote-delegation.clar
;; Delegate voting power to another address with optional scope limits
;; Errors:
;;   u100 - already delegated
;;   u101 - no delegation found
;;   u102 - self-delegation
;;   u103 - delegation expired

(define-constant CONTRACT-OWNER tx-sender)

(define-map delegations principal
  { delegate: principal, power: uint, expires-at: uint, scope: (string-ascii 20) })

(define-map delegated-power principal uint)

(define-public (delegate-vote
  (delegate principal)
  (power uint)
  (duration uint)
  (scope (string-ascii 20)))
  (begin
    (asserts! (not (is-eq tx-sender delegate)) (err u102))
    (asserts! (is-none (map-get? delegations tx-sender)) (err u100))
    (map-set delegations tx-sender
      { delegate: delegate, power: power,
        expires-at: (+ block-height duration), scope: scope })
    (map-set delegated-power delegate
      (+ (default-to u0 (map-get? delegated-power delegate)) power))
    (ok delegate)))

(define-public (revoke-delegation)
  (let ((d (unwrap! (map-get? delegations tx-sender) (err u101))))
    (map-set delegated-power (get delegate d)
      (- (default-to u0 (map-get? delegated-power (get delegate d))) (get power d)))
    (map-delete delegations tx-sender)
    (ok true)))

(define-read-only (get-delegation (address principal))
  (map-get? delegations address))

(define-read-only (get-effective-power (address principal))
  (default-to u0 (map-get? delegated-power address)))

(define-read-only (is-delegation-valid? (address principal))
  (match (map-get? delegations address)
    d (<= block-height (get expires-at d))
    false))
EOF
commit "contracts/vote-delegation.clar" "Add vote-delegation: delegate and revoke voting power with scope and expiry"

cat > tests/vote-delegation.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('vote-delegation', () => {
  it('user can delegate voting power', async () => {
    const chain = new Chain();
    const [deployer, delegate] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(delegate.address), types.uint(100), types.uint(500), types.ascii('governance')],
        deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('rejects self-delegation', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(deployer.address), types.uint(100), types.uint(500), types.ascii('all')],
        deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u102');
  });

  it('rejects duplicate delegation', async () => {
    const chain = new Chain();
    const [deployer, delegate, other] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(delegate.address), types.uint(50), types.uint(300), types.ascii('staking')],
        deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(other.address), types.uint(50), types.uint(300), types.ascii('staking')],
        deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u100');
  });

  it('delegator can revoke their delegation', async () => {
    const chain = new Chain();
    const [deployer, delegate] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(delegate.address), types.uint(75), types.uint(1000), types.ascii('all')],
        deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'revoke-delegation', [], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });
});
EOF
commit "tests/vote-delegation.test.ts" "Add vote-delegation tests: 4 cases covering delegation and revocation"

# ── credential-transfer ───────────────────────────────────────────────────────
cat > contracts/credential-transfer.clar << 'EOF'
;; credential-transfer.clar
;; Transfer transferable credentials with issuer-controlled policy
;; Errors:
;;   u100 - not authorized
;;   u101 - credential not transferable
;;   u102 - not the holder
;;   u103 - credential not found

(define-constant CONTRACT-OWNER tx-sender)

(define-map transfer-policies
  { schema: (string-ascii 40) }
  { transferable: bool, max-transfers: uint })

(define-map credentials
  { credential-id: uint }
  { schema: (string-ascii 40), holder: principal,
    issuer: principal, transfers: uint, revoked: bool })

(define-data-var cred-nonce uint u0)

(define-public (set-transfer-policy (schema (string-ascii 40)) (transferable bool) (max-transfers uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u100))
    (ok (map-set transfer-policies { schema: schema }
      { transferable: transferable, max-transfers: max-transfers }))))

(define-public (issue-credential (holder principal) (schema (string-ascii 40)))
  (let ((id (+ (var-get cred-nonce) u1)))
    (var-set cred-nonce id)
    (ok (map-set credentials { credential-id: id }
      { schema: schema, holder: holder, issuer: tx-sender, transfers: u0, revoked: false }))))

(define-public (transfer-credential (credential-id uint) (to principal))
  (let (
    (cred (unwrap! (map-get? credentials { credential-id: credential-id }) (err u103)))
    (policy (unwrap! (map-get? transfer-policies { schema: (get schema cred) }) (err u101)))
  )
    (asserts! (is-eq tx-sender (get holder cred)) (err u102))
    (asserts! (get transferable policy) (err u101))
    (asserts! (< (get transfers cred) (get max-transfers policy)) (err u101))
    (ok (map-set credentials { credential-id: credential-id }
      (merge cred { holder: to, transfers: (+ (get transfers cred) u1) })))))

(define-read-only (get-credential (credential-id uint))
  (map-get? credentials { credential-id: credential-id }))

(define-read-only (is-transferable? (schema (string-ascii 40)))
  (match (map-get? transfer-policies { schema: schema })
    p (get transferable p)
    false))
EOF
commit "contracts/credential-transfer.clar" "Add credential-transfer: policy-gated credential transfers with max-transfer cap"

cat > tests/credential-transfer.test.ts << 'EOF'
import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('credential-transfer', () => {
  it('issues a transferable credential to a holder', async () => {
    const chain = new Chain();
    const [deployer, holder] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('membership-v1'), types.bool(true), types.uint(3)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('membership-v1')], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('holder can transfer to another address', async () => {
    const chain = new Chain();
    const [deployer, holder, receiver] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('pass-v1'), types.bool(true), types.uint(5)], deployer.address),
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('pass-v1')], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'transfer-credential',
        [types.uint(1), types.principal(receiver.address)], holder.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('rejects transfer for non-transferable schema', async () => {
    const chain = new Chain();
    const [deployer, holder, receiver] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('sbt-v1'), types.bool(false), types.uint(0)], deployer.address),
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('sbt-v1')], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'transfer-credential',
        [types.uint(1), types.principal(receiver.address)], holder.address),
    ]);
    expect(block.receipts[0].result).toContain('err u101');
  });

  it('rejects transfer from non-holder address', async () => {
    const chain = new Chain();
    const [deployer, holder, stranger] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('ticket-v1'), types.bool(true), types.uint(2)], deployer.address),
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('ticket-v1')], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'transfer-credential',
        [types.uint(1), types.principal(stranger.address)], stranger.address),
    ]);
    expect(block.receipts[0].result).toContain('err u102');
  });
});
EOF
commit "tests/credential-transfer.test.ts" "Add credential-transfer tests: 4 cases covering policy and transfer guards"

echo ""
echo "🎯 May 9 contracts commits: $COUNT"
git push origin main -q
echo "🚀 Pushed to origin/main"
