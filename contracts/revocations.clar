;; revocations.clar
;; ProofLedger Credential Revocation Registry
;; Revoke previously anchored documents with reason and audit trail

(define-map revocations
  { hash: (buff 32) }
  { revoker: principal, reason: (string-ascii 200),
    revoked-at: uint, original-owner: (optional principal) })

(define-map revocation-challenges
  { hash: (buff 32), challenger: principal }
  { reason: (string-ascii 200), challenged-at: uint })

(define-data-var total-revocations uint u0)

;; revoke: issuer or owner revokes a credential
;; Errors: u1 = already revoked
(define-public (revoke (hash (buff 32)) (reason (string-ascii 200))
                         (original-owner (optional principal)))
  (begin
    (asserts! (is-none (map-get? revocations { hash: hash })) (err u1))
    (map-set revocations { hash: hash }
      { revoker: tx-sender, reason: reason,
        revoked-at: stacks-block-height,
        original-owner: original-owner })
    (var-set total-revocations (+ (var-get total-revocations) u1))
    (ok true)))

;; challenge-revocation: document owner contests a revocation
;; Errors: u2 = not revoked, u3 = already challenged
(define-public (challenge-revocation (hash (buff 32)) (reason (string-ascii 200)))
  (begin
    (asserts! (is-some (map-get? revocations { hash: hash })) (err u2))
    (asserts! (is-none (map-get? revocation-challenges
      { hash: hash, challenger: tx-sender })) (err u3))
    (map-set revocation-challenges { hash: hash, challenger: tx-sender }
      { reason: reason, challenged-at: stacks-block-height })
    (ok true)))

(define-read-only (is-revoked (hash (buff 32)))
  (is-some (map-get? revocations { hash: hash })))

(define-read-only (get-revocation (hash (buff 32)))
  (map-get? revocations { hash: hash }))

(define-read-only (get-total-revocations) (var-get total-revocations))