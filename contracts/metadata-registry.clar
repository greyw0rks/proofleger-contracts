;; metadata-registry.clar
;; ProofLedger Metadata Registry
;; Link off-chain metadata URIs to on-chain anchored document hashes

(define-map metadata-entries
  { hash: (buff 32) }
  { uri:         (string-ascii 150),
    content-type: (string-ascii 40),
    added-by:    principal,
    added-at:    uint,
    pinned:      bool })

(define-map uri-counts
  { submitter: principal }
  { count: uint })

(define-data-var registry-admin principal tx-sender)
(define-data-var total-entries  uint u0)

;; register: link a metadata URI to an anchored document hash
;; Errors: u1 = already registered
(define-public (register (hash         (buff 32))
                           (uri          (string-ascii 150))
                           (content-type (string-ascii 40)))
  (begin
    (asserts! (is-none (map-get? metadata-entries { hash: hash })) (err u1))
    (map-set metadata-entries { hash: hash }
      { uri:          uri,
        content-type: content-type,
        added-by:     tx-sender,
        added-at:     stacks-block-height,
        pinned:       false })
    (let ((cur (default-to u0 (get count (map-get? uri-counts { submitter: tx-sender })))))
      (map-set uri-counts { submitter: tx-sender } { count: (+ cur u1) }))
    (var-set total-entries (+ (var-get total-entries) u1))
    (ok true)))

;; update-uri: owner updates a metadata pointer
;; Errors: u2 = not found, u3 = not owner
(define-public (update-uri (hash (buff 32)) (new-uri (string-ascii 150)))
  (let ((entry (unwrap! (map-get? metadata-entries { hash: hash }) (err u2))))
    (asserts! (is-eq tx-sender (get added-by entry)) (err u3))
    (map-set metadata-entries { hash: hash }
      (merge entry { uri: new-uri }))
    (ok true)))

;; pin: admin marks a metadata entry as pinned
(define-public (pin (hash (buff 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get registry-admin)) (err u401))
    (let ((entry (unwrap! (map-get? metadata-entries { hash: hash }) (err u2))))
      (map-set metadata-entries { hash: hash } (merge entry { pinned: true }))
      (ok true))))

(define-read-only (get-metadata (hash (buff 32)))
  (map-get? metadata-entries { hash: hash }))

(define-read-only (get-uri (hash (buff 32)))
  (match (map-get? metadata-entries { hash: hash })
    e (some (get uri e))
    none))

(define-read-only (get-total-entries) (var-get total-entries))