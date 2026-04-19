;; staking.clar
;; ProofLedger Staking
;; Credential holders stake STX to earn yield and increase reputation

(define-map stakes
  { staker: principal }
  { amount: uint, staked-at: uint,
    last-claim: uint, total-claimed: uint })

(define-map staking-rewards
  { epoch: uint }
  { total-staked: uint, reward-pool: uint, distributed: bool })

(define-data-var total-staked uint u0)
(define-data-var epoch-count uint u0)
(define-data-var contract-owner principal tx-sender)

;; stake: deposit STX into the staking pool
;; Errors: u1 = zero amount, u2 = already staking (use add-stake)
(define-public (stake (amount uint))
  (begin
    (asserts! (> amount u0) (err u1))
    (asserts! (is-none (map-get? stakes { staker: tx-sender })) (err u2))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set stakes { staker: tx-sender }
      { amount: amount, staked-at: stacks-block-height,
        last-claim: stacks-block-height, total-claimed: u0 })
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok true)))

;; unstake: withdraw STX from the pool
;; Errors: u3 = no stake found
(define-public (unstake)
  (let ((s (unwrap! (map-get? stakes { staker: tx-sender }) (err u3))))
    (try! (as-contract (stx-transfer? (get amount s) tx-sender tx-sender)))
    (var-set total-staked (- (var-get total-staked) (get amount s)))
    (map-delete stakes { staker: tx-sender })
    (ok (get amount s))))

;; fund-rewards: owner adds to the reward pool for an epoch
(define-public (fund-rewards (amount uint))
  (let ((epoch (+ (var-get epoch-count) u1)))
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u401))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set staking-rewards { epoch: epoch }
      { total-staked: (var-get total-staked), reward-pool: amount, distributed: false })
    (var-set epoch-count epoch)
    (ok epoch)))

(define-read-only (get-stake (staker principal))
  (map-get? stakes { staker: staker }))

(define-read-only (get-total-staked) (var-get total-staked))