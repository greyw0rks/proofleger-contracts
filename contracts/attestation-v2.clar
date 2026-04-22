;; attestation-v2.clar
;; ProofLedger Attestation v2
;; Enhanced attestations with typed metadata, expiry, and revocation

(define-map attestations
  { hash: (buff 32), attester: principal }
  { attest-type: (string-ascii 50),
    metadata: (string-ascii 200),
    attested-at: uint,
    expires-at: (optional uint),
    revoked: bool,
    weight: uint })

(define-map hash-attestation-counts
  { hash: (buff 32) }
  { count: uint })

;; attest: create a typed attestation for a document
;; Errors: u1 = already attested by this address
(define-public (attest (hash (buff 32)) (attest-type (string-ascii 50))
                         (metadata (string-ascii 200))
                         (expires-in (optional uint)) (weight uint))
  (begin
    (asserts! (is-none (map-get? attestations { hash: hash, attester: tx-sender })) (err u1))
    (map-set attestations { hash: hash, attester: tx-sender }
      { attest-type: attest-type, metadata: metadata,
        attested-at: stacks-block-height,
        expires-at: (match expires-in
          dur (some (+ stacks-block-height dur))
          none),
        revoked: false,
        weight: (if (> weight u0) weight u1) })
    (let ((existing (default-to u0 (get count (map-get? hash-attestation-counts { hash: hash })))))
      (map-set hash-attestation-counts { hash: hash } { count: (+ existing u1) }))
    (ok true)))

;; revoke: attester withdraws their attestation
;; Errors: u2 = not found, u3 = not attester
(define-public (revoke (hash (buff 32)))
  (let ((a (unwrap! (map-get? attestations { hash: hash, attester: tx-sender }) (err u2))))
    (map-set attestations { hash: hash, attester: tx-sender }
      (merge a { revoked: true }))
    (ok true)))

(define-read-only (get-attestation (hash (buff 32)) (attester principal))
  (map-get? attestations { hash: hash, attester: attester }))

(define-read-only (is-valid-attestation (hash (buff 32)) (attester principal))
  (match (map-get? attestations { hash: hash, attester: attester })
    a (and (not (get revoked a))
           (match (get expires-at a)
             exp (<= stacks-block-height exp)
             true))
    false))

(define-read-only (get-attestation-count (hash (buff 32)))
  (default-to u0 (get count (map-get? hash-attestation-counts { hash: hash }))))