;; issuer-registry.clar
;; ProofLedger Issuer Registry
;; On-chain directory of verified credential issuers

(define-map issuers
  { address: principal }
  { name:         (string-ascii 80),
    url:          (string-ascii 120),
    issuer-type:  (string-ascii 40),  ;; university | employer | government | dao | other
    verified:     bool,
    registered-at: uint,
    active:       bool })

(define-map issuer-stats
  { address: principal }
  { total-issued: uint, last-issued-at: uint })

(define-data-var registry-admin principal tx-sender)
(define-data-var total-issuers  uint u0)

;; self-register: any principal registers as a credential issuer
(define-public (self-register (name (string-ascii 80))
                                (url (string-ascii 120))
                                (issuer-type (string-ascii 40)))
  (begin
    (asserts! (is-none (map-get? issuers { address: tx-sender })) (err u1))
    (map-set issuers { address: tx-sender }
      { name:          name,
        url:           url,
        issuer-type:   issuer-type,
        verified:      false,
        registered-at: stacks-block-height,
        active:        true })
    (var-set total-issuers (+ (var-get total-issuers) u1))
    (ok true)))

;; verify-issuer: admin marks an issuer as officially verified
;; Errors: u2 = not admin, u3 = issuer not found
(define-public (verify-issuer (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get registry-admin)) (err u2))
    (let ((issuer (unwrap! (map-get? issuers { address: address }) (err u3))))
      (map-set issuers { address: address }
        (merge issuer { verified: true }))
      (ok true))))

;; deactivate-issuer: admin deactivates a misbehaving issuer
(define-public (deactivate-issuer (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get registry-admin)) (err u2))
    (let ((issuer (unwrap! (map-get? issuers { address: address }) (err u3))))
      (map-set issuers { address: address }
        (merge issuer { active: false }))
      (ok true))))

;; record-issuance: called when an issuer anchors a credential
(define-public (record-issuance (issuer principal))
  (begin
    (asserts! (is-some (map-get? issuers { address: issuer })) (err u3))
    (let ((stats (default-to { total-issued: u0, last-issued-at: u0 }
                   (map-get? issuer-stats { address: issuer }))))
      (map-set issuer-stats { address: issuer }
        { total-issued:    (+ (get total-issued stats) u1),
          last-issued-at:  stacks-block-height }))
    (ok true)))

(define-read-only (get-issuer (address principal))
  (map-get? issuers { address: address }))

(define-read-only (is-verified-issuer (address principal))
  (match (map-get? issuers { address: address })
    i (and (get verified i) (get active i))
    false))

(define-read-only (get-issuer-stats (address principal))
  (map-get? issuer-stats { address: address }))

(define-read-only (get-total-issuers) (var-get total-issuers))