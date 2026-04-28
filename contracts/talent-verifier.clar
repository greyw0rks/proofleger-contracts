;; talent-verifier.clar
;; ProofLedger Talent Protocol Integration
;; Record verified Talent Protocol builder scores on-chain

(define-map talent-attestations
  { address: principal }
  { builder-score:  uint,
    passport-id:    (string-ascii 80),
    attested-by:    principal,
    attested-at:    uint,
    score-valid:    bool,
    last-updated:   uint })

(define-map attestation-counts
  { attester: principal }
  { count: uint })

(define-data-var talent-admin    principal tx-sender)
(define-data-var total-attested  uint u0)
(define-data-var min-score       uint u0) ;; configurable minimum score threshold

;; attest: authorized attester records a builder score
;; Errors: u401 = not admin
(define-public (attest (address      principal)
                        (builder-score uint)
                        (passport-id  (string-ascii 80)))
  (begin
    (asserts! (is-eq tx-sender (var-get talent-admin)) (err u401))
    (let ((existing (map-get? talent-attestations { address: address })))
      (map-set talent-attestations { address: address }
        { builder-score: builder-score,
          passport-id:   passport-id,
          attested-by:   tx-sender,
          attested-at:   (if (is-none existing) stacks-block-height
                           (get attested-at (unwrap-panic existing))),
          score-valid:   (>= builder-score (var-get min-score)),
          last-updated:  stacks-block-height })
      (when (is-none existing)
        (var-set total-attested (+ (var-get total-attested) u1)))
      (let ((cur (default-to u0 (get count (map-get? attestation-counts { attester: tx-sender })))))
        (map-set attestation-counts { attester: tx-sender } { count: (+ cur u1) }))
      (ok builder-score))))

;; revoke: admin invalidates an attestation
;; Errors: u401 = not admin, u1 = not found
(define-public (revoke (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get talent-admin)) (err u401))
    (let ((a (unwrap! (map-get? talent-attestations { address: address }) (err u1))))
      (map-set talent-attestations { address: address }
        (merge a { score-valid: false, last-updated: stacks-block-height }))
      (ok true))))

(define-public (set-min-score (score uint))
  (begin
    (asserts! (is-eq tx-sender (var-get talent-admin)) (err u401))
    (var-set min-score score)
    (ok score)))

(define-read-only (get-attestation (address principal))
  (map-get? talent-attestations { address: address }))

(define-read-only (is-verified (address principal))
  (match (map-get? talent-attestations { address: address })
    a (get score-valid a)
    false))

(define-read-only (get-score (address principal))
  (match (map-get? talent-attestations { address: address })
    a (some (get builder-score a))
    none))

(define-read-only (get-total-attested) (var-get total-attested))