;; credential-transfer.clar
;; Transfer transferable credentials with issuer-controlled policy
;; Errors:
;;   u100 - not authorized
;;   u101 - credential not transferable
;;   u102 - not the holder
;;   u103 - credential not found

(define-constant CONTRACT-OWNER tx-sender)

(define-map transfer-policies
  { schema: (string-ascii 40) }
  { transferable: bool, max-transfers: uint })

(define-map credentials
  { credential-id: uint }
  { schema: (string-ascii 40), holder: principal,
    issuer: principal, transfers: uint, revoked: bool })

(define-data-var cred-nonce uint u0)

(define-public (set-transfer-policy (schema (string-ascii 40)) (transferable bool) (max-transfers uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u100))
    (ok (map-set transfer-policies { schema: schema }
      { transferable: transferable, max-transfers: max-transfers }))))

(define-public (issue-credential (holder principal) (schema (string-ascii 40)))
  (let ((id (+ (var-get cred-nonce) u1)))
    (var-set cred-nonce id)
    (ok (map-set credentials { credential-id: id }
      { schema: schema, holder: holder, issuer: tx-sender, transfers: u0, revoked: false }))))

(define-public (transfer-credential (credential-id uint) (to principal))
  (let (
    (cred (unwrap! (map-get? credentials { credential-id: credential-id }) (err u103)))
    (policy (unwrap! (map-get? transfer-policies { schema: (get schema cred) }) (err u101)))
  )
    (asserts! (is-eq tx-sender (get holder cred)) (err u102))
    (asserts! (get transferable policy) (err u101))
    (asserts! (< (get transfers cred) (get max-transfers policy)) (err u101))
    (ok (map-set credentials { credential-id: credential-id }
      (merge cred { holder: to, transfers: (+ (get transfers cred) u1) })))))

(define-read-only (get-credential (credential-id uint))
  (map-get? credentials { credential-id: credential-id }))

(define-read-only (is-transferable? (schema (string-ascii 40)))
  (match (map-get? transfer-policies { schema: schema })
    p (get transferable p)
    false))
