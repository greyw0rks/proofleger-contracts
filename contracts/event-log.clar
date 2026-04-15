;; event-log.clar
;; ProofLedger Audit Event Log
;; Immutable, append-only log of protocol events for auditability

(define-map events
  { index: uint }
  { event-type: (string-ascii 50), actor: principal,
    subject: (optional principal), hash: (optional (buff 32)),
    data: (string-ascii 200), logged-at: uint })

(define-data-var event-count uint u0)

;; log-event: append an event to the audit log
(define-public (log-event (event-type (string-ascii 50))
                           (subject (optional principal))
                           (hash (optional (buff 32)))
                           (data (string-ascii 200)))
  (let ((idx (var-get event-count)))
    (map-set events { index: idx }
      { event-type: event-type, actor: tx-sender,
        subject: subject, hash: hash,
        data: data, logged-at: stacks-block-height })
    (var-set event-count (+ idx u1))
    (ok idx)))

(define-read-only (get-event (index uint))
  (map-get? events { index: index }))

(define-read-only (get-event-count)
  (var-get event-count))