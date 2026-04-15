;; community-pool.clar
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
  (map-get? contributions { contributor: contributor }))