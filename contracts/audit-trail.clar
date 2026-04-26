;; audit-trail.clar
;; ProofLedger Audit Trail
;; Append-only record of governance and admin actions

(define-map audit-entries
  { entry-id: uint }
  { actor:       principal,
    action:      (string-ascii 80),
    target:      (string-ascii 80),
    recorded-at: uint,
    note:        (string-ascii 200) })

(define-data-var audit-admin   principal tx-sender)
(define-data-var entry-count   uint u0)
(define-data-var open-writes   bool true) ;; allow any principal to log their own actions

;; log: record an administrative action
(define-public (log (action (string-ascii 80))
                     (target (string-ascii 80))
                     (note   (string-ascii 200)))
  (begin
    (asserts! (or (var-get open-writes)
                  (is-eq tx-sender (var-get audit-admin))) (err u401))
    (let ((id (+ (var-get entry-count) u1)))
      (map-set audit-entries { entry-id: id }
        { actor:       tx-sender,
          action:      action,
          target:      target,
          recorded-at: stacks-block-height,
          note:        note })
      (var-set entry-count id)
      (ok id))))

;; set-open-writes: admin locks writes to admin-only if needed
(define-public (set-open-writes (open bool))
  (begin
    (asserts! (is-eq tx-sender (var-get audit-admin)) (err u401))
    (var-set open-writes open)
    (ok true)))

(define-read-only (get-entry (entry-id uint))
  (map-get? audit-entries { entry-id: entry-id }))

(define-read-only (get-entry-count) (var-get entry-count))
(define-read-only (writes-open)     (var-get open-writes))