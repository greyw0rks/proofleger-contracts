;; credential-expiry.clar
;; ProofLedger Credential Expiry
;; Issue credentials with block-based expiry and renewal support

(define-map timed-credentials
  { cred-id: uint }
  { issuer:      principal,
    holder:      principal,
    hash:        (buff 32),
    issued-at:   uint,
    expires-at:  uint,
    renewed:     uint,       ;; count of renewals
    active:      bool })

(define-data-var cred-count    uint u0)
(define-data-var expiry-admin  principal tx-sender)

;; issue: issuer creates a time-limited credential
;; Errors: u1 = expiry must be in the future
(define-public (issue (holder     principal)
                       (hash       (buff 32))
                       (expires-at uint))
  (begin
    (asserts! (> expires-at stacks-block-height) (err u1))
    (let ((id (+ (var-get cred-count) u1)))
      (map-set timed-credentials { cred-id: id }
        { issuer:     tx-sender,
          holder:     holder,
          hash:       hash,
          issued-at:  stacks-block-height,
          expires-at: expires-at,
          renewed:    u0,
          active:     true })
      (var-set cred-count id)
      (ok id))))

;; renew: issuer extends the credential expiry
;; Errors: u2 = not found, u3 = not issuer, u4 = new expiry must be later
(define-public (renew (cred-id uint) (new-expires-at uint))
  (let ((c (unwrap! (map-get? timed-credentials { cred-id: cred-id }) (err u2))))
    (asserts! (is-eq tx-sender (get issuer c))          (err u3))
    (asserts! (> new-expires-at (get expires-at c))     (err u4))
    (map-set timed-credentials { cred-id: cred-id }
      (merge c { expires-at: new-expires-at, renewed: (+ (get renewed c) u1) }))
    (ok new-expires-at)))

;; revoke: issuer deactivates a credential before expiry
;; Errors: u2 = not found, u3 = not issuer
(define-public (revoke (cred-id uint))
  (let ((c (unwrap! (map-get? timed-credentials { cred-id: cred-id }) (err u2))))
    (asserts! (is-eq tx-sender (get issuer c)) (err u3))
    (map-set timed-credentials { cred-id: cred-id }
      (merge c { active: false }))
    (ok true)))

(define-read-only (is-valid (cred-id uint))
  (match (map-get? timed-credentials { cred-id: cred-id })
    c (and (get active c) (< stacks-block-height (get expires-at c)))
    false))

(define-read-only (get-credential (cred-id uint))
  (map-get? timed-credentials { cred-id: cred-id }))

(define-read-only (get-cred-count) (var-get cred-count))