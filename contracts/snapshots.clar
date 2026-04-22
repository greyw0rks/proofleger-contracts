;; snapshots.clar
;; ProofLedger State Snapshots
;; Periodic anchoring of protocol state for historical analytics

(define-map snapshots
  { id: uint }
  { snapshotter: principal,
    total-anchors: uint, total-attests: uint,
    total-wallets: uint, block-height: uint,
    timestamp: uint, note: (string-ascii 100) })

(define-data-var snapshot-count uint u0)
(define-data-var min-interval uint u144) ;; ~1 day between snapshots
(define-data-var last-snapshot-block uint u0)

;; take-snapshot: record current protocol state
;; Errors: u1 = too soon since last snapshot
(define-public (take-snapshot (total-anchors uint) (total-attests uint)
                                (total-wallets uint) (note (string-ascii 100)))
  (begin
    (asserts! (>= (- stacks-block-height (var-get last-snapshot-block))
                  (var-get min-interval)) (err u1))
    (let ((id (+ (var-get snapshot-count) u1)))
      (map-set snapshots { id: id }
        { snapshotter: tx-sender,
          total-anchors: total-anchors, total-attests: total-attests,
          total-wallets: total-wallets,
          block-height: stacks-block-height,
          timestamp: stacks-block-height,
          note: note })
      (var-set snapshot-count id)
      (var-set last-snapshot-block stacks-block-height)
      (ok id))))

(define-read-only (get-snapshot (id uint))
  (map-get? snapshots { id: id }))

(define-read-only (get-latest-snapshot)
  (map-get? snapshots { id: (var-get snapshot-count) }))

(define-read-only (get-snapshot-count) (var-get snapshot-count))