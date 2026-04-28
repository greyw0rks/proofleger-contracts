;; document-hash-v2.clar
;; ProofLedger Document Hash v2
;; Extended anchoring with IPFS metadata pointer and optional expiry

(define-map doc-hashes
  { hash: (buff 32) }
  { title:        (string-ascii 100),
    doc-type:     (string-ascii 50),
    meta-uri:     (string-ascii 150),  ;; ipfs:// or ar:// pointer to metadata JSON
    submitter:    principal,
    anchored-at:  uint,
    expires-at:   uint,               ;; 0 = never expires
    revoked:      bool })

(define-data-var owner      principal tx-sender)
(define-data-var total      uint u0)
(define-data-var open-anchoring bool true)

;; anchor: submit a document with optional metadata URI and expiry
;; Errors: u1 = already anchored, u2 = closed
(define-public (anchor (hash      (buff 32))
                        (title     (string-ascii 100))
                        (doc-type  (string-ascii 50))
                        (meta-uri  (string-ascii 150))
                        (expires-at uint))
  (begin
    (asserts! (var-get open-anchoring) (err u2))
    (asserts! (is-none (map-get? doc-hashes { hash: hash })) (err u1))
    (map-set doc-hashes { hash: hash }
      { title:       title,
        doc-type:    doc-type,
        meta-uri:    meta-uri,
        submitter:   tx-sender,
        anchored-at: stacks-block-height,
        expires-at:  expires-at,
        revoked:     false })
    (var-set total (+ (var-get total) u1))
    (ok true)))

;; revoke: submitter revokes their document
;; Errors: u3 = not found, u4 = not submitter
(define-public (revoke (hash (buff 32)))
  (let ((d (unwrap! (map-get? doc-hashes { hash: hash }) (err u3))))
    (asserts! (is-eq tx-sender (get submitter d)) (err u4))
    (map-set doc-hashes { hash: hash } (merge d { revoked: true }))
    (ok true)))

(define-read-only (get-document (hash (buff 32)))
  (map-get? doc-hashes { hash: hash }))

(define-read-only (is-valid (hash (buff 32)))
  (match (map-get? doc-hashes { hash: hash })
    d (and
        (not (get revoked d))
        (or (is-eq (get expires-at d) u0)
            (< stacks-block-height (get expires-at d))))
    false))

(define-read-only (get-total) (var-get total))