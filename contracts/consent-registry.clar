;; consent-registry.clar
;; ProofLedger Consent Registry
;; Record and manage data processing consent on-chain

(define-map consents
  { subject: principal, processor: principal, purpose: (string-ascii 100) }
  { granted-at: uint, expires-at: (optional uint),
    revoked: bool, revoked-at: (optional uint),
    proof-hash: (optional (buff 32)) })

(define-data-var total-consents uint u0)

;; grant-consent: subject grants consent to a data processor
(define-public (grant-consent (processor principal) (purpose (string-ascii 100))
                                (expires-in (optional uint)) (proof-hash (optional (buff 32))))
  (begin
    (asserts! (not (is-eq tx-sender processor)) (err u1))
    (map-set consents { subject: tx-sender, processor: processor, purpose: purpose }
      { granted-at: stacks-block-height,
        expires-at: (match expires-in
          duration (some (+ stacks-block-height duration))
          none),
        revoked: false, revoked-at: none, proof-hash: proof-hash })
    (var-set total-consents (+ (var-get total-consents) u1))
    (ok true)))

;; revoke-consent: subject withdraws consent
;; Errors: u2 = consent not found, u3 = already revoked
(define-public (revoke-consent (processor principal) (purpose (string-ascii 100)))
  (let ((consent (unwrap! (map-get? consents { subject: tx-sender, processor: processor, purpose: purpose }) (err u2))))
    (asserts! (not (get revoked consent)) (err u3))
    (map-set consents { subject: tx-sender, processor: processor, purpose: purpose }
      (merge consent { revoked: true, revoked-at: (some stacks-block-height) }))
    (ok true)))

(define-read-only (has-valid-consent (subject principal) (processor principal) (purpose (string-ascii 100)))
  (match (map-get? consents { subject: subject, processor: processor, purpose: purpose })
    c (and (not (get revoked c))
           (match (get expires-at c)
             exp (<= stacks-block-height exp)
             true))
    false))

(define-read-only (get-consent (subject principal) (processor principal) (purpose (string-ascii 100)))
  (map-get? consents { subject: subject, processor: processor, purpose: purpose }))