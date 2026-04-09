;; staking.clar
;; ProofLedger Reputation Staking
;; Stake STX to signal commitment to the ProofLedger ecosystem

(define-fungible-token proof-stake)

(define-map stakes
  { staker: principal }
  { amount: uint, staked-at: uint, unlock-at: uint })

(define-data-var total-staked uint u0)
(define-constant LOCK_PERIOD u144) ;; ~1 day in blocks

;; stake: lock STX tokens to signal ecosystem commitment
;; Errors: u1 = already staking, u2 = amount must be positive
(define-public (stake (amount uint))
  (begin
    (asserts! (is-none (map-get? stakes { staker: tx-sender })) (err u1))
    (asserts! (> amount u0) (err u2))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set stakes { staker: tx-sender }
      { amount: amount, staked-at: stacks-block-height, unlock-at: (+ stacks-block-height LOCK_PERIOD) })
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok true)))

;; unstake: withdraw STX after lock period expires
;; Errors: u3 = no stake found, u4 = still locked
(define-public (unstake)
  (let ((stake-data (unwrap! (map-get? stakes { staker: tx-sender }) (err u3))))
    (asserts! (>= stacks-block-height (get unlock-at stake-data)) (err u4))
    (let ((amount (get amount stake-data)))
      (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
      (map-delete stakes { staker: tx-sender })
      (var-set total-staked (- (var-get total-staked) amount))
      (ok amount))))

(define-read-only (get-stake (staker principal))
  (map-get? stakes { staker: staker }))

(define-read-only (get-total-staked)
  (var-get total-staked))