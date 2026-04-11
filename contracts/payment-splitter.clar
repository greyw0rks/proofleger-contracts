;; payment-splitter.clar
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
  (map-get? splits { id: id }))