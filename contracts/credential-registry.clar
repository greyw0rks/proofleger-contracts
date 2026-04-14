;; credential-registry.clar
;; ProofLedger Global Credential Registry
;; Index all issued credentials by type for discovery

(define-map credentials-by-type
  { cred-type: (string-ascii 50), index: uint }
  { hash: (buff 32), issuer: principal, issued-at: uint })

(define-map type-counts
  { cred-type: (string-ascii 50) }
  { count: uint })

(define-map credential-info
  { hash: (buff 32) }
  { cred-type: (string-ascii 50), issuer: principal,
    subject: principal, issued-at: uint, title: (string-ascii 100) })

(define-data-var total-credentials uint u0)

;; register-credential: add a credential to the global registry
(define-public (register-credential (hash (buff 32)) (cred-type (string-ascii 50))
                                     (subject principal) (title (string-ascii 100)))
  (let ((count (default-to u0 (get count (map-get? type-counts { cred-type: cred-type })))))
    (asserts! (is-none (map-get? credential-info { hash: hash })) (err u1))
    (map-set credential-info { hash: hash }
      { cred-type: cred-type, issuer: tx-sender, subject: subject,
        issued-at: stacks-block-height, title: title })
    (map-set credentials-by-type { cred-type: cred-type, index: count }
      { hash: hash, issuer: tx-sender, issued-at: stacks-block-height })
    (map-set type-counts { cred-type: cred-type } { count: (+ count u1) })
    (var-set total-credentials (+ (var-get total-credentials) u1))
    (ok true)))

(define-read-only (get-credential (hash (buff 32)))
  (map-get? credential-info { hash: hash }))

(define-read-only (get-type-count (cred-type (string-ascii 50)))
  (default-to u0 (get count (map-get? type-counts { cred-type: cred-type }))))

(define-read-only (get-total-credentials) (var-get total-credentials))