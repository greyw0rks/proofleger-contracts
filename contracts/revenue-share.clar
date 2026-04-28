;; revenue-share.clar
;; ProofLedger Revenue Share
;; Accumulate protocol fees and distribute proportionally to stakers

(define-map claimable
  { staker: principal }
  { amount-ustx: uint, last-claimed: uint })

(define-data-var rev-admin     principal tx-sender)
(define-data-var total-pool    uint u0)
(define-data-var total-claimed uint u0)

;; deposit: admin adds revenue to the distribution pool
;; Errors: u401 = not admin
(define-public (deposit (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get rev-admin)) (err u401))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set total-pool (+ (var-get total-pool) amount))
    (ok amount)))

;; allocate: admin sets claimable amount for a staker based on weight
;; Errors: u401 = not admin
(define-public (allocate (staker principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get rev-admin)) (err u401))
    (let ((cur (default-to u0 (get amount-ustx (map-get? claimable { staker: staker })))))
      (map-set claimable { staker: staker }
        { amount-ustx: (+ cur amount), last-claimed: u0 })
      (ok (+ cur amount)))))

;; claim: staker withdraws their allocated share
;; Errors: u1 = nothing to claim
(define-public (claim)
  (let ((entry (unwrap! (map-get? claimable { staker: tx-sender }) (err u1))))
    (let ((amount (get amount-ustx entry)))
      (asserts! (> amount u0) (err u1))
      (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
      (map-set claimable { staker: tx-sender }
        { amount-ustx: u0, last-claimed: stacks-block-height })
      (var-set total-claimed (+ (var-get total-claimed) amount))
      (ok amount))))

(define-read-only (get-claimable (staker principal))
  (default-to u0 (get amount-ustx (map-get? claimable { staker: staker }))))

(define-read-only (get-total-pool)    (var-get total-pool))
(define-read-only (get-total-claimed) (var-get total-claimed))