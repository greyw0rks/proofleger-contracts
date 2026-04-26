;; staking.clar
;; ProofLedger Staking
;; Stake STX tokens to earn voting weight and protocol rewards

(define-map stakes
  { staker: principal }
  { amount:      uint,
    staked-at:   uint,
    lock-until:  uint,
    weight:      uint })

(define-data-var staking-admin   principal tx-sender)
(define-data-var staking-vault   principal tx-sender)
(define-data-var total-staked    uint u0)
(define-data-var min-stake       uint u1000000) ;; 1 STX minimum
(define-data-var lock-period     uint u1440)    ;; ~10 days in blocks

;; stake: lock STX and earn governance weight
;; Errors: u1 = below minimum, u2 = already staked
(define-public (stake (amount uint))
  (begin
    (asserts! (>= amount (var-get min-stake)) (err u1))
    (asserts! (is-none (map-get? stakes { staker: tx-sender })) (err u2))
    (try! (stx-transfer? amount tx-sender (var-get staking-vault)))
    (let ((lock (+ stacks-block-height (var-get lock-period)))
          (weight (/ amount u1000000))) ;; 1 weight per STX
      (map-set stakes { staker: tx-sender }
        { amount: amount, staked-at: stacks-block-height,
          lock-until: lock, weight: weight })
      (var-set total-staked (+ (var-get total-staked) amount))
      (ok weight))))

;; unstake: withdraw STX after lock period expires
;; Errors: u3 = not found, u4 = still locked
(define-public (unstake)
  (let ((s (unwrap! (map-get? stakes { staker: tx-sender }) (err u3))))
    (asserts! (>= stacks-block-height (get lock-until s)) (err u4))
    (try! (as-contract (stx-transfer? (get amount s) tx-sender tx-sender)))
    (map-delete stakes { staker: tx-sender })
    (var-set total-staked (- (var-get total-staked) (get amount s)))
    (ok (get amount s))))

(define-read-only (get-stake (staker principal))
  (map-get? stakes { staker: staker }))

(define-read-only (get-weight (staker principal))
  (default-to u0 (get weight (map-get? stakes { staker: staker }))))

(define-read-only (get-total-staked) (var-get total-staked))

(define-read-only (is-locked (staker principal))
  (match (map-get? stakes { staker: staker })
    s (< stacks-block-height (get lock-until s))
    false))