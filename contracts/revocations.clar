;; revocations.clar
;; ProofLedger Revocation Registry
;; Allows document owners to publicly flag anchored hashes as revoked

(define-map revocations
  { hash: (buff 32) }
  { revoker: principal, revoked-at: uint, reason: (string-ascii 100) })

;; revoke-document
;; Publicly revokes an anchored document hash
;; Errors: u1 = already revoked
(define-public (revoke-document (hash (buff 32)) (reason (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? revocations { hash: hash })) (err u1))
    (map-set revocations { hash: hash }
      { revoker: tx-sender, revoked-at: stacks-block-height, reason: reason })
    (ok true)))

(define-read-only (is-revoked (hash (buff 32)))
  (is-some (map-get? revocations { hash: hash })))

(define-read-only (get-revocation (hash (buff 32)))
  (map-get? revocations { hash: hash }))