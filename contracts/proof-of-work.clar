;; proof-of-work.clar
;; ProofLedger Proof of Work
;; Contributors log work items on-chain with associated document hashes

(define-map work-logs
  { contributor: principal, index: uint }
  { hash: (buff 32), description: (string-ascii 200),
    work-type: (string-ascii 50), hours: uint, logged-at: uint })

(define-map work-count
  { contributor: principal }
  { count: uint, total-hours: uint })

;; log-work: record a work item with an associated document proof
;; Errors: u1 = hours must be positive
(define-public (log-work (hash (buff 32)) (description (string-ascii 200))
                          (work-type (string-ascii 50)) (hours uint))
  (let ((existing (default-to { count: u0, total-hours: u0 }
          (map-get? work-count { contributor: tx-sender })))
        (idx (get count existing)))
    (asserts! (> hours u0) (err u1))
    (map-set work-logs { contributor: tx-sender, index: idx }
      { hash: hash, description: description, work-type: work-type,
        hours: hours, logged-at: stacks-block-height })
    (map-set work-count { contributor: tx-sender }
      { count: (+ idx u1), total-hours: (+ (get total-hours existing) hours) })
    (ok idx)))

(define-read-only (get-work-log (contributor principal) (index uint))
  (map-get? work-logs { contributor: contributor, index: index }))

(define-read-only (get-work-summary (contributor principal))
  (map-get? work-count { contributor: contributor }))