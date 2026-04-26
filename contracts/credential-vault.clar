;; credential-vault.clar
;; ProofLedger Credential Vault
;; Store encrypted credential references and grant selective access

(define-map vault-entries
  { vault-id: uint }
  { owner:        principal,
    cipher-ref:   (string-ascii 200),  ;; IPFS CID or arweave tx of encrypted payload
    doc-type:     (string-ascii 50),
    created-at:   uint,
    access-count: uint })

(define-map access-grants
  { vault-id: uint, grantee: principal }
  { granted-at: uint, expires-at: uint, active: bool })

(define-data-var vault-count uint u0)

;; store: owner adds an encrypted credential reference to their vault
(define-public (store (cipher-ref (string-ascii 200)) (doc-type (string-ascii 50)))
  (let ((id (+ (var-get vault-count) u1)))
    (map-set vault-entries { vault-id: id }
      { owner:        tx-sender,
        cipher-ref:   cipher-ref,
        doc-type:     doc-type,
        created-at:   stacks-block-height,
        access-count: u0 })
    (var-set vault-count id)
    (ok id)))

;; grant-access: owner shares a vault entry with a grantee
;; Errors: u1 = not found, u2 = not owner
(define-public (grant-access (vault-id uint) (grantee principal) (expires-at uint))
  (let ((entry (unwrap! (map-get? vault-entries { vault-id: vault-id }) (err u1))))
    (asserts! (is-eq tx-sender (get owner entry)) (err u2))
    (map-set access-grants { vault-id: vault-id, grantee: grantee }
      { granted-at: stacks-block-height, expires-at: expires-at, active: true })
    (map-set vault-entries { vault-id: vault-id }
      (merge entry { access-count: (+ (get access-count entry) u1) }))
    (ok true)))

;; revoke-access: owner removes a grantee
;; Errors: u1 = not found, u2 = not owner
(define-public (revoke-access (vault-id uint) (grantee principal))
  (let ((entry (unwrap! (map-get? vault-entries { vault-id: vault-id }) (err u1))))
    (asserts! (is-eq tx-sender (get owner entry)) (err u2))
    (map-set access-grants { vault-id: vault-id, grantee: grantee }
      { granted-at: u0, expires-at: u0, active: false })
    (ok true)))

(define-read-only (has-access (vault-id uint) (grantee principal))
  (match (map-get? access-grants { vault-id: vault-id, grantee: grantee })
    g (and (get active g)
           (or (is-eq (get expires-at g) u0)
               (< stacks-block-height (get expires-at g))))
    false))

(define-read-only (get-vault-entry (vault-id uint))
  (map-get? vault-entries { vault-id: vault-id }))

(define-read-only (get-vault-count) (var-get vault-count))