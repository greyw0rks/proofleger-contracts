;; notary-v2.clar
;; ProofLedger Notary v2
;; Document notarization with optional witness co-signatures

(define-map notarizations
  { notary-id: uint }
  { hash:          (buff 32),
    title:         (string-ascii 100),
    notary:        principal,
    witness-1:     (optional principal),
    witness-2:     (optional principal),
    notarized-at:  uint,
    witness-count: uint,
    sealed:        bool })

(define-map witness-sigs
  { notary-id: uint, witness: principal }
  { signed-at: uint })

(define-data-var notary-count uint u0)

;; notarize: create a notarization record
(define-public (notarize (hash  (buff 32))
                           (title (string-ascii 100)))
  (let ((id (+ (var-get notary-count) u1)))
    (map-set notarizations { notary-id: id }
      { hash:          hash,
        title:         title,
        notary:        tx-sender,
        witness-1:     none,
        witness-2:     none,
        notarized-at:  stacks-block-height,
        witness-count: u0,
        sealed:        false })
    (var-set notary-count id)
    (ok id)))

;; co-sign: a witness adds their signature
;; Errors: u1 = not found, u2 = already sealed, u3 = notary cannot be witness
(define-public (co-sign (notary-id uint))
  (let ((n (unwrap! (map-get? notarizations { notary-id: notary-id }) (err u1))))
    (asserts! (not (get sealed n))           (err u2))
    (asserts! (not (is-eq tx-sender (get notary n))) (err u3))
    (asserts! (is-none (map-get? witness-sigs { notary-id: notary-id, witness: tx-sender })) (err u4))
    (map-set witness-sigs { notary-id: notary-id, witness: tx-sender }
      { signed-at: stacks-block-height })
    (let ((wc (+ (get witness-count n) u1)))
      (map-set notarizations { notary-id: notary-id }
        (merge n { witness-count: wc,
                   witness-1: (if (is-eq wc u1) (some tx-sender) (get witness-1 n)),
                   witness-2: (if (is-eq wc u2) (some tx-sender) (get witness-2 n)) }))
      (ok wc))))

;; seal: notary locks the record after witnesses have signed
;; Errors: u1 = not found, u5 = not notary
(define-public (seal (notary-id uint))
  (let ((n (unwrap! (map-get? notarizations { notary-id: notary-id }) (err u1))))
    (asserts! (is-eq tx-sender (get notary n)) (err u5))
    (map-set notarizations { notary-id: notary-id }
      (merge n { sealed: true }))
    (ok true)))

(define-read-only (get-notarization (notary-id uint))
  (map-get? notarizations { notary-id: notary-id }))

(define-read-only (is-witness (notary-id uint) (witness principal))
  (is-some (map-get? witness-sigs { notary-id: notary-id, witness: witness })))

(define-read-only (get-notary-count) (var-get notary-count))