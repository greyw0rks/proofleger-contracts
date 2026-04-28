;; vault-access-log.clar
;; ProofLedger Vault Access Log
;; Append-only record of who accessed which vault entries and when

(define-map access-events
  { event-id: uint }
  { vault-id:   uint,
    accessor:   principal,
    owner:      principal,
    event-type: (string-ascii 20),  ;; grant | revoke | view
    occurred-at: uint })

(define-map vault-event-counts
  { vault-id: uint }
  { count: uint })

(define-data-var event-count uint u0)

;; log-event: record a vault access event
(define-public (log-event (vault-id  uint)
                            (owner     principal)
                            (event-type (string-ascii 20)))
  (let ((id (+ (var-get event-count) u1)))
    (map-set access-events { event-id: id }
      { vault-id:    vault-id,
        accessor:    tx-sender,
        owner:       owner,
        event-type:  event-type,
        occurred-at: stacks-block-height })
    (let ((vc (default-to u0 (get count (map-get? vault-event-counts { vault-id: vault-id })))))
      (map-set vault-event-counts { vault-id: vault-id } { count: (+ vc u1) }))
    (var-set event-count id)
    (ok id)))

(define-read-only (get-event (event-id uint))
  (map-get? access-events { event-id: event-id }))

(define-read-only (get-vault-event-count (vault-id uint))
  (default-to u0 (get count (map-get? vault-event-counts { vault-id: vault-id }))))

(define-read-only (get-event-count) (var-get event-count))