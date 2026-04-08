;; timestamps.clar
;; ProofLedger General Timestamp Anchoring
;; Prove when any string identifier (URL, content ID, etc.) first existed

(define-map timestamps
  { id: (string-ascii 256) }
  { creator: principal, block-height: uint })

(define-data-var total-timestamps uint u0)

;; anchor-timestamp: record when an identifier was first seen
;; Errors: u1 = already anchored
(define-public (anchor-timestamp (id (string-ascii 256)))
  (begin
    (asserts! (is-none (map-get? timestamps { id: id })) (err u1))
    (asserts! (> (len id) u0) (err u2))
    (map-set timestamps { id: id }
      { creator: tx-sender, block-height: stacks-block-height })
    (var-set total-timestamps (+ (var-get total-timestamps) u1))
    (ok true)))

(define-read-only (get-timestamp (id (string-ascii 256)))
  (map-get? timestamps { id: id }))

(define-read-only (was-anchored (id (string-ascii 256)))
  (is-some (map-get? timestamps { id: id })))

(define-read-only (get-total)
  (var-get total-timestamps))