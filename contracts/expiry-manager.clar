;; expiry-manager.clar
;; ProofLedger Expiry Manager
;; Track expiry status for documents and flag those past their deadline

(define-map expiry-records
  { record-id: uint }
  { hash:         (buff 32),
    owner:        principal,
    expires-at:   uint,
    flagged:      bool,
    flagged-at:   uint })

(define-map owner-expiry-counts
  { owner: principal }
  { count: uint })

(define-data-var expiry-admin  principal tx-sender)
(define-data-var record-count  uint u0)
(define-data-var total-flagged uint u0)

;; register: record an expiry deadline for a document
(define-public (register (hash       (buff 32))
                           (expires-at uint))
  (begin
    (asserts! (> expires-at stacks-block-height) (err u1))
    (let ((id (+ (var-get record-count) u1)))
      (map-set expiry-records { record-id: id }
        { hash:       hash,
          owner:      tx-sender,
          expires-at: expires-at,
          flagged:    false,
          flagged-at: u0 })
      (let ((cur (default-to u0 (get count (map-get? owner-expiry-counts { owner: tx-sender })))))
        (map-set owner-expiry-counts { owner: tx-sender } { count: (+ cur u1) }))
      (var-set record-count id)
      (ok id))))

;; flag-expired: admin or anyone flags a record that has passed expiry
;; Errors: u2 = not found, u3 = not yet expired, u4 = already flagged
(define-public (flag-expired (record-id uint))
  (let ((r (unwrap! (map-get? expiry-records { record-id: record-id }) (err u2))))
    (asserts! (>= stacks-block-height (get expires-at r)) (err u3))
    (asserts! (not (get flagged r))                       (err u4))
    (map-set expiry-records { record-id: record-id }
      (merge r { flagged: true, flagged-at: stacks-block-height }))
    (var-set total-flagged (+ (var-get total-flagged) u1))
    (ok true)))

(define-read-only (is-expired (record-id uint))
  (match (map-get? expiry-records { record-id: record-id })
    r (>= stacks-block-height (get expires-at r))
    false))

(define-read-only (get-record (record-id uint))
  (map-get? expiry-records { record-id: record-id }))

(define-read-only (get-record-count)  (var-get record-count))
(define-read-only (get-total-flagged) (var-get total-flagged))