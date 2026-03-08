(define-map attestations { hash: (buff 32), issuer: principal } { credential-type: (string-ascii 50), issued-at: uint })
(define-map attestation-count { hash: (buff 32) } { count: uint })
(define-map attestation-index { hash: (buff 32), index: uint } { issuer: principal })

(define-public (attest (hash (buff 32)) (credential-type (string-ascii 50)))
  (let ((existing (map-get? attestations { hash: hash, issuer: tx-sender }))
        (count (default-to u0 (get count (map-get? attestation-count { hash: hash })))))
    (asserts! (is-none existing) (err u1))
    (map-set attestations { hash: hash, issuer: tx-sender } { credential-type: credential-type, issued-at: block-height })
    (map-set attestation-count { hash: hash } { count: (+ count u1) })
    (map-set attestation-index { hash: hash, index: count } { issuer: tx-sender })
    (ok true)))

(define-read-only (get-attestation (hash (buff 32)) (issuer principal))
  (map-get? attestations { hash: hash, issuer: issuer }))

(define-read-only (get-attestation-count (hash (buff 32)))
  (default-to u0 (get count (map-get? attestation-count { hash: hash }))))

(define-read-only (get-attestation-at (hash (buff 32)) (index uint))
  (match (map-get? attestation-index { hash: hash, index: index })
    entry (map-get? attestations { hash: hash, issuer: (get issuer entry) })
    none))
