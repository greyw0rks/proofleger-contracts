;; proof-bundle.clar
;; ProofLedger Proof Bundle
;; Group related document hashes under a named collection

(define-map bundles
  { bundle-id: uint }
  { name:       (string-ascii 80),
    creator:    principal,
    created-at: uint,
    hash-count: uint,
    sealed:     bool })

(define-map bundle-hashes
  { bundle-id: uint, index: uint }
  { hash:  (buff 32),
    label: (string-ascii 60) })

(define-data-var bundle-count uint u0)

;; create-bundle: creator starts a new named bundle
(define-public (create-bundle (name (string-ascii 80)))
  (let ((id (+ (var-get bundle-count) u1)))
    (map-set bundles { bundle-id: id }
      { name:       name,
        creator:    tx-sender,
        created-at: stacks-block-height,
        hash-count: u0,
        sealed:     false })
    (var-set bundle-count id)
    (ok id)))

;; add-hash: append a hash to an unsealed bundle
;; Errors: u1 = not found, u2 = not creator, u3 = sealed
(define-public (add-hash (bundle-id uint)
                           (hash      (buff 32))
                           (label     (string-ascii 60)))
  (let ((b (unwrap! (map-get? bundles { bundle-id: bundle-id }) (err u1))))
    (asserts! (is-eq tx-sender (get creator b)) (err u2))
    (asserts! (not (get sealed b))              (err u3))
    (let ((idx (get hash-count b)))
      (map-set bundle-hashes { bundle-id: bundle-id, index: idx }
        { hash: hash, label: label })
      (map-set bundles { bundle-id: bundle-id }
        (merge b { hash-count: (+ idx u1) }))
      (ok (+ idx u1)))))

;; seal: creator locks the bundle against further additions
;; Errors: u1 = not found, u2 = not creator
(define-public (seal (bundle-id uint))
  (let ((b (unwrap! (map-get? bundles { bundle-id: bundle-id }) (err u1))))
    (asserts! (is-eq tx-sender (get creator b)) (err u2))
    (map-set bundles { bundle-id: bundle-id } (merge b { sealed: true }))
    (ok true)))

(define-read-only (get-bundle (bundle-id uint))
  (map-get? bundles { bundle-id: bundle-id }))

(define-read-only (get-bundle-hash (bundle-id uint) (index uint))
  (map-get? bundle-hashes { bundle-id: bundle-id, index: index }))

(define-read-only (get-bundle-count) (var-get bundle-count))