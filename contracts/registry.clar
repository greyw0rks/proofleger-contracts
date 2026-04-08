;; registry.clar
;; ProofLedger Trusted Issuer Registry
;; Maintains a list of verified credential-issuing institutions

(define-map issuers
  { address: principal }
  { name: (string-ascii 100), url: (string-ascii 200), verified: bool, registered-at: uint })

(define-data-var contract-owner principal tx-sender)
(define-data-var total-issuers uint u0)

;; register-issuer: register as a credential issuer (unverified)
;; Errors: u1 = already registered
(define-public (register-issuer (name (string-ascii 100)) (url (string-ascii 200)))
  (begin
    (asserts! (is-none (map-get? issuers { address: tx-sender })) (err u1))
    (map-set issuers { address: tx-sender }
      { name: name, url: url, verified: false, registered-at: stacks-block-height })
    (var-set total-issuers (+ (var-get total-issuers) u1))
    (ok true)))

;; verify-issuer: contract owner marks an issuer as verified
;; Errors: u403 = not owner, u404 = issuer not found
(define-public (verify-issuer (issuer principal))
  (let ((existing (unwrap! (map-get? issuers { address: issuer }) (err u404))))
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (map-set issuers { address: issuer } (merge existing { verified: true }))
    (ok true)))

(define-read-only (is-verified-issuer (address principal))
  (default-to false (get verified (map-get? issuers { address: address }))))

(define-read-only (get-issuer (address principal))
  (map-get? issuers { address: address }))