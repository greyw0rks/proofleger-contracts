;; zkp-verifier.clar
;; ProofLedger ZKP Attestation Registry
;; Record on-chain that a ZK proof for a credential was verified off-chain

(define-map zkp-attestations
  { attest-id: uint }
  { credential-hash: (buff 32),
    proof-type:      (string-ascii 40),   ;; groth16 | plonk | stark | other
    verifier:        principal,
    verified-at:     uint,
    public-inputs:   (string-ascii 200),  ;; JSON-encoded public signals
    valid:           bool })

(define-map verifier-counts
  { verifier: principal }
  { count: uint })

(define-data-var attest-count uint u0)
(define-data-var zkp-admin    principal tx-sender)

;; attest: record that a ZK proof was verified for a credential hash
(define-public (attest (credential-hash (buff 32))
                        (proof-type     (string-ascii 40))
                        (public-inputs  (string-ascii 200))
                        (valid          bool))
  (let ((id (+ (var-get attest-count) u1)))
    (map-set zkp-attestations { attest-id: id }
      { credential-hash: credential-hash,
        proof-type:      proof-type,
        verifier:        tx-sender,
        verified-at:     stacks-block-height,
        public-inputs:   public-inputs,
        valid:           valid })
    (let ((cur (default-to u0 (get count (map-get? verifier-counts { verifier: tx-sender })))))
      (map-set verifier-counts { verifier: tx-sender } { count: (+ cur u1) }))
    (var-set attest-count id)
    (ok id)))

(define-read-only (get-attestation (attest-id uint))
  (map-get? zkp-attestations { attest-id: attest-id }))

(define-read-only (get-verifier-count (verifier principal))
  (default-to u0 (get count (map-get? verifier-counts { verifier: verifier }))))

(define-read-only (get-total-attestations) (var-get attest-count))