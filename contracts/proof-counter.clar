;; proof-counter.clar
;; ProofLedger Proof Counter
;; Track per-wallet action counts and emit milestone events

(define-map counters
  { address: principal }
  { anchors:    uint,
    attests:    uint,
    verifies:   uint,
    last-action: uint })

(define-map milestones
  { address: principal, milestone: uint }
  { reached-at: uint, action-type: (string-ascii 20) })

(define-data-var counter-admin principal tx-sender)
(define-data-var total-actions uint u0)

(define-constant MILESTONES (list u1 u5 u10 u25 u50 u100))

;; increment-anchor: admin increments anchor count and checks milestones
;; Errors: u401 = not admin
(define-public (increment-anchor (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get counter-admin)) (err u401))
    (let* ((c   (get-or-init address))
           (new (+ (get anchors c) u1)))
      (map-set counters { address: address }
        (merge c { anchors: new, last-action: stacks-block-height }))
      (var-set total-actions (+ (var-get total-actions) u1))
      ;; Record milestone if hit
      (if (or (is-eq new u1) (is-eq new u5) (is-eq new u10)
              (is-eq new u25) (is-eq new u50) (is-eq new u100))
        (map-set milestones { address: address, milestone: new }
          { reached-at: stacks-block-height, action-type: "anchor" })
        true)
      (ok new))))

;; increment-attest: admin increments attest count
(define-public (increment-attest (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get counter-admin)) (err u401))
    (let* ((c (get-or-init address))
           (new (+ (get attests c) u1)))
      (map-set counters { address: address }
        (merge c { attests: new, last-action: stacks-block-height }))
      (var-set total-actions (+ (var-get total-actions) u1))
      (ok new))))

(define-private (get-or-init (address principal))
  (default-to
    { anchors: u0, attests: u0, verifies: u0, last-action: u0 }
    (map-get? counters { address: address })))

(define-read-only (get-counters (address principal))
  (map-get? counters { address: address }))

(define-read-only (get-milestone (address principal) (milestone uint))
  (map-get? milestones { address: address, milestone: milestone }))

(define-read-only (get-anchor-count (address principal))
  (default-to u0 (get anchors (map-get? counters { address: address }))))

(define-read-only (get-total-actions) (var-get total-actions))