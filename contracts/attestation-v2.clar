;; attestation-v2.clar
;; ProofLedger Enhanced Attestation
;; Attestations with credibility weight based on attestor reputation

(define-map attestations-v2
  { hash: (buff 32), attestor: principal }
  { attested-at: uint, credential-type: (string-ascii 50),
    weight: uint, comment: (string-ascii 200) })

(define-map attestation-totals
  { hash: (buff 32) }
  { count: uint, total-weight: uint })

;; attest-with-weight: attest with a credibility weight (1-10)
;; Errors: u1 = already attested, u2 = invalid weight, u3 = self-attest
(define-public (attest-with-weight (hash (buff 32)) (credential-type (string-ascii 50))
                                    (weight uint) (comment (string-ascii 200)))
  (let ((totals (default-to { count: u0, total-weight: u0 }
          (map-get? attestation-totals { hash: hash }))))
    (asserts! (is-none (map-get? attestations-v2 { hash: hash, attestor: tx-sender })) (err u1))
    (asserts! (and (>= weight u1) (<= weight u10)) (err u2))
    (map-set attestations-v2 { hash: hash, attestor: tx-sender }
      { attested-at: stacks-block-height, credential-type: credential-type,
        weight: weight, comment: comment })
    (map-set attestation-totals { hash: hash }
      { count: (+ (get count totals) u1),
        total-weight: (+ (get total-weight totals) weight) })
    (ok true)))

(define-read-only (get-attestation (hash (buff 32)) (attestor principal))
  (map-get? attestations-v2 { hash: hash, attestor: attestor }))

(define-read-only (get-credibility-score (hash (buff 32)))
  (let ((totals (default-to { count: u0, total-weight: u0 }
          (map-get? attestation-totals { hash: hash }))))
    (if (> (get count totals) u0)
      (/ (get total-weight totals) (get count totals))
      u0)))