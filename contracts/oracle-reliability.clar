;; oracle-reliability.clar  generated: jun8
;; Errors: u100 not-authorized  u101 not-found  u102 already-exists
(define-constant CONTRACT-OWNER tx-sender)
(define-map oracle_reliability_entries { entry-id: uint }
  { owner: principal, value: (buff 32), block: uint, active: bool })
(define-data-var entry-nonce uint u0)
(define-data-var total-entries uint u0)
(define-public (add-entry (value (buff 32)))
  (let ((id (+ (var-get entry-nonce) u1)))
    (var-set entry-nonce id)
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok (map-set oracle_reliability_entries { entry-id: id }
      { owner: tx-sender, value: value, block: block-height, active: true }))))
(define-public (deactivate-entry (id uint))
  (let ((e (unwrap! (map-get? oracle_reliability_entries { entry-id: id }) (err u101))))
    (asserts! (is-eq tx-sender (get owner e)) (err u100))
    (ok (map-set oracle_reliability_entries { entry-id: id } (merge e { active: false })))))
(define-read-only (get-entry (id uint)) (map-get? oracle_reliability_entries { entry-id: id }))
(define-read-only (get-total) (var-get total-entries))
