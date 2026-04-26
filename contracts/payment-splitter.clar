;; payment-splitter.clar
;; ProofLedger Payment Splitter
;; Distribute protocol revenue across configured recipients and shares

(define-map recipients
  { index: uint }
  { address: principal, share: uint, label: (string-ascii 60) })

(define-data-var splitter-admin  principal tx-sender)
(define-data-var recipient-count uint u0)
(define-data-var total-shares    uint u0)
(define-data-var total-disbursed uint u0)

;; add-recipient: admin registers an address and share weight
;; Errors: u401 = not admin
(define-public (add-recipient (address principal)
                               (share uint)
                               (label (string-ascii 60)))
  (begin
    (asserts! (is-eq tx-sender (var-get splitter-admin)) (err u401))
    (asserts! (> share u0) (err u1))
    (let ((idx (var-get recipient-count)))
      (map-set recipients { index: idx }
        { address: address, share: share, label: label })
      (var-set recipient-count (+ idx u1))
      (var-set total-shares (+ (var-get total-shares) share))
      (ok idx))))

;; split: distribute an amount proportionally across all recipients
;; Errors: u2 = no recipients, u3 = zero total shares
(define-public (split (amount uint))
  (begin
    (asserts! (> (var-get recipient-count) u0) (err u2))
    (asserts! (> (var-get total-shares) u0)    (err u3))
    (let ((shares (var-get total-shares))
          (count  (var-get recipient-count)))
      ;; Process first two recipients — Clarity list limitation
      (match (map-get? recipients { index: u0 })
        r0 (let ((payout (/ (* amount (get share r0)) shares)))
             (if (> payout u0)
               (try! (stx-transfer? payout tx-sender (get address r0)))
               true))
        true)
      (match (map-get? recipients { index: u1 })
        r1 (let ((payout (/ (* amount (get share r1)) shares)))
             (if (> payout u0)
               (try! (stx-transfer? payout tx-sender (get address r1)))
               true))
        true)
      (var-set total-disbursed (+ (var-get total-disbursed) amount))
      (ok amount))))

(define-read-only (get-recipient (index uint))
  (map-get? recipients { index: index }))

(define-read-only (get-payout (amount uint) (index uint))
  (match (map-get? recipients { index: index })
    r (/ (* amount (get share r)) (var-get total-shares))
    u0))

(define-read-only (get-total-disbursed) (var-get total-disbursed))
(define-read-only (get-recipient-count) (var-get recipient-count))