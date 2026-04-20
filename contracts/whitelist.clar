;; whitelist.clar
;; ProofLedger Issuer Whitelist
;; Manage approved institutions that can issue credentials

(define-map whitelist
  { issuer: principal }
  { name: (string-ascii 100), category: (string-ascii 50),
    approved-at: uint, approved-by: principal, active: bool })

(define-map whitelist-requests
  { requester: principal }
  { name: (string-ascii 100), category: (string-ascii 50),
    requested-at: uint, approved: bool })

(define-data-var whitelist-admin principal tx-sender)
(define-data-var total-approved uint u0)

;; request-approval: institution requests whitelist inclusion
;; Errors: u1 = already whitelisted
(define-public (request-approval (name (string-ascii 100)) (category (string-ascii 50)))
  (begin
    (asserts! (is-none (map-get? whitelist { issuer: tx-sender })) (err u1))
    (map-set whitelist-requests { requester: tx-sender }
      { name: name, category: category,
        requested-at: stacks-block-height, approved: false })
    (ok true)))

;; approve-issuer: admin adds an institution to the whitelist
;; Errors: u401 = not admin
(define-public (approve-issuer (issuer principal) (name (string-ascii 100)) (category (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get whitelist-admin)) (err u401))
    (map-set whitelist { issuer: issuer }
      { name: name, category: category,
        approved-at: stacks-block-height, approved-by: tx-sender, active: true })
    (var-set total-approved (+ (var-get total-approved) u1))
    (match (map-get? whitelist-requests { requester: issuer })
      req (map-set whitelist-requests { requester: issuer } (merge req { approved: true }))
      true)
    (ok true)))

;; revoke-issuer: admin removes from whitelist
(define-public (revoke-issuer (issuer principal))
  (begin
    (asserts! (is-eq tx-sender (var-get whitelist-admin)) (err u401))
    (match (map-get? whitelist { issuer: issuer })
      w (map-set whitelist { issuer: issuer } (merge w { active: false }))
      true)
    (ok true)))

(define-read-only (is-approved (issuer principal))
  (default-to false (get active (map-get? whitelist { issuer: issuer }))))

(define-read-only (get-issuer-info (issuer principal))
  (map-get? whitelist { issuer: issuer }))