;; attestation-registry.clar
;; ProofLedger Attestation Registry
;; Any principal may attest to a document hash from another submitter

(define-map attestations
  { hash: (buff 32), attester: principal }
  { note:        (string-ascii 150),
    attested-at: uint,
    weight:      uint })  ;; optional weight from staking contract

(define-map hash-attest-counts
  { hash: (buff 32) }
  { count: uint, total-weight: uint })

(define-map attester-counts
  { attester: principal }
  { count: uint })

(define-data-var total-attestations uint u0)

;; attest: record an attestation for a document hash
;; Errors: u1 = already attested this hash
(define-public (attest (hash   (buff 32))
                        (note   (string-ascii 150))
                        (weight uint))
  (begin
    (asserts! (is-none (map-get? attestations { hash: hash, attester: tx-sender })) (err u1))
    (map-set attestations { hash: hash, attester: tx-sender }
      { note: note, attested-at: stacks-block-height, weight: weight })
    (let ((hc (default-to { count: u0, total-weight: u0 }
                (map-get? hash-attest-counts { hash: hash }))))
      (map-set hash-attest-counts { hash: hash }
        { count: (+ (get count hc) u1),
          total-weight: (+ (get total-weight hc) weight) }))
    (let ((ac (default-to u0 (get count (map-get? attester-counts { attester: tx-sender })))))
      (map-set attester-counts { attester: tx-sender } { count: (+ ac u1) }))
    (var-set total-attestations (+ (var-get total-attestations) u1))
    (ok true)))

;; retract: remove your own attestation
;; Errors: u2 = not found
(define-public (retract (hash (buff 32)))
  (begin
    (asserts! (is-some (map-get? attestations { hash: hash, attester: tx-sender })) (err u2))
    (map-delete attestations { hash: hash, attester: tx-sender })
    (ok true)))

(define-read-only (get-attestation (hash (buff 32)) (attester principal))
  (map-get? attestations { hash: hash, attester: attester }))

(define-read-only (get-hash-stats (hash (buff 32)))
  (default-to { count: u0, total-weight: u0 }
    (map-get? hash-attest-counts { hash: hash })))

(define-read-only (get-attester-count (attester principal))
  (default-to u0 (get count (map-get? attester-counts { attester: attester }))))

(define-read-only (get-total-attestations) (var-get total-attestations))