;; expiring-credentials.clar
;; ProofLedger Expiring Credentials
;; Issue credentials that expire at a specific block height

(define-map expiring-creds
  { hash: (buff 32) }
  { issuer: principal, subject: principal,
    cred-type: (string-ascii 50), issued-at: uint,
    expires-at: uint, revoked: bool })

(define-data-var total-issued uint u0)

;; issue-expiring: issue a credential that expires after a set number of blocks
;; Errors: u1 = hash already issued, u2 = duration must be positive
(define-public (issue-expiring (hash (buff 32)) (subject principal)
                                (cred-type (string-ascii 50)) (duration uint))
  (begin
    (asserts! (is-none (map-get? expiring-creds { hash: hash })) (err u1))
    (asserts! (> duration u0) (err u2))
    (map-set expiring-creds { hash: hash }
      { issuer: tx-sender, subject: subject, cred-type: cred-type,
        issued-at: stacks-block-height,
        expires-at: (+ stacks-block-height duration),
        revoked: false })
    (var-set total-issued (+ (var-get total-issued) u1))
    (ok true)))

;; revoke: issuer revokes a credential before expiry
;; Errors: u3 = not found, u4 = not issuer
(define-public (revoke (hash (buff 32)))
  (let ((cred (unwrap! (map-get? expiring-creds { hash: hash }) (err u3))))
    (asserts! (is-eq tx-sender (get issuer cred)) (err u4))
    (map-set expiring-creds { hash: hash } (merge cred { revoked: true }))
    (ok true)))

(define-read-only (is-valid (hash (buff 32)))
  (match (map-get? expiring-creds { hash: hash })
    cred (and (not (get revoked cred)) (<= stacks-block-height (get expires-at cred)))
    false))

(define-read-only (get-credential (hash (buff 32)))
  (map-get? expiring-creds { hash: hash }))