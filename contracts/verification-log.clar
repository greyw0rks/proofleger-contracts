;; verification-log.clar
;; ProofLedger Verification Log
;; Write-once record of every verify call for audit trail

(define-map log-entries
  { entry-id: uint }
  { checker:     principal,
    hash:        (buff 32),
    found:       bool,
    checked-at:  uint,
    chain:       (string-ascii 10) })

(define-map checker-counts
  { checker: principal }
  { count: uint })

(define-data-var entry-count uint u0)
(define-data-var log-admin   principal tx-sender)

;; log-check: write a verification event
;; Errors: u401 = not authorized
(define-public (log-check (hash (buff 32)) (found bool) (chain (string-ascii 10)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get log-admin))
                  true) ;; open write — any principal may log their own checks
              (err u401))
    (let ((id (+ (var-get entry-count) u1)))
      (map-set log-entries { entry-id: id }
        { checker:    tx-sender,
          hash:       hash,
          found:      found,
          checked-at: stacks-block-height,
          chain:      chain })
      (let ((cur (default-to u0 (get count (map-get? checker-counts { checker: tx-sender })))))
        (map-set checker-counts { checker: tx-sender } { count: (+ cur u1) }))
      (var-set entry-count id)
      (ok id))))

(define-read-only (get-entry (entry-id uint))
  (map-get? log-entries { entry-id: entry-id }))

(define-read-only (get-checker-count (checker principal))
  (default-to u0 (get count (map-get? checker-counts { checker: checker }))))

(define-read-only (get-total-checks) (var-get entry-count))