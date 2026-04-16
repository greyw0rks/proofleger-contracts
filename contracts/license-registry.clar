;; license-registry.clar
;; ProofLedger Professional License Registry
;; Issue and track professional licenses with renewal tracking

(define-map licenses
  { hash: (buff 32) }
  { issuing-body: principal, licensee: principal,
    license-type: (string-ascii 50), jurisdiction: (string-ascii 50),
    issued-at: uint, expires-at: uint, renewed-count: uint,
    active: bool })

(define-map license-by-type
  { license-type: (string-ascii 50), index: uint }
  { hash: (buff 32) })

(define-map type-counts
  { license-type: (string-ascii 50) }
  { count: uint })

(define-data-var total-licenses uint u0)

;; issue-license: issue a professional license with expiry
(define-public (issue-license (hash (buff 32)) (licensee principal)
                                (license-type (string-ascii 50))
                                (jurisdiction (string-ascii 50))
                                (duration uint))
  (let ((count (default-to u0 (get count (map-get? type-counts { license-type: license-type })))))
    (asserts! (is-none (map-get? licenses { hash: hash })) (err u1))
    (asserts! (> duration u0) (err u2))
    (map-set licenses { hash: hash }
      { issuing-body: tx-sender, licensee: licensee,
        license-type: license-type, jurisdiction: jurisdiction,
        issued-at: stacks-block-height,
        expires-at: (+ stacks-block-height duration),
        renewed-count: u0, active: true })
    (map-set license-by-type { license-type: license-type, index: count } { hash: hash })
    (map-set type-counts { license-type: license-type } { count: (+ count u1) })
    (var-set total-licenses (+ (var-get total-licenses) u1))
    (ok true)))

;; renew-license: extend license expiry
;; Errors: u3 = not found, u4 = not issuing body
(define-public (renew-license (hash (buff 32)) (extension uint))
  (let ((lic (unwrap! (map-get? licenses { hash: hash }) (err u3))))
    (asserts! (is-eq tx-sender (get issuing-body lic)) (err u4))
    (map-set licenses { hash: hash }
      (merge lic { expires-at: (+ (get expires-at lic) extension),
                   renewed-count: (+ (get renewed-count lic) u1) }))
    (ok true)))

(define-read-only (is-active-license (hash (buff 32)))
  (match (map-get? licenses { hash: hash })
    l (and (get active l) (<= stacks-block-height (get expires-at l)))
    false))

(define-read-only (get-license (hash (buff 32)))
  (map-get? licenses { hash: hash }))