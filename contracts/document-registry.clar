;; document-registry.clar
;; ProofLedger Document Registry
;; Canonical index mapping hashes to metadata and issuer addresses

(define-map documents
  { hash: (buff 32) }
  { title:       (string-ascii 100),
    doc-type:    (string-ascii 50),
    issuer:      principal,
    anchored-at: uint,
    active:      bool,
    revision:    uint })

(define-map issuer-counts
  { issuer: principal }
  { count: uint })

(define-data-var registry-admin principal tx-sender)
(define-data-var total-documents uint u0)

;; register: add a document to the registry
;; Errors: u1 = already registered
(define-public (register (hash (buff 32)) (title (string-ascii 100))
                           (doc-type (string-ascii 50)))
  (begin
    (asserts! (is-none (map-get? documents { hash: hash })) (err u1))
    (map-set documents { hash: hash }
      { title:       title,
        doc-type:    doc-type,
        issuer:      tx-sender,
        anchored-at: stacks-block-height,
        active:      true,
        revision:    u1 })
    (let ((cur (default-to u0 (get count (map-get? issuer-counts { issuer: tx-sender })))))
      (map-set issuer-counts { issuer: tx-sender } { count: (+ cur u1) }))
    (var-set total-documents (+ (var-get total-documents) u1))
    (ok true)))

;; revoke: issuer deactivates their document entry
;; Errors: u2 = not found, u3 = not issuer
(define-public (revoke (hash (buff 32)))
  (let ((doc (unwrap! (map-get? documents { hash: hash }) (err u2))))
    (asserts! (is-eq tx-sender (get issuer doc)) (err u3))
    (map-set documents { hash: hash }
      (merge doc { active: false }))
    (ok true)))

;; update-title: issuer corrects the document title, bumps revision
;; Errors: u2 = not found, u3 = not issuer
(define-public (update-title (hash (buff 32)) (new-title (string-ascii 100)))
  (let ((doc (unwrap! (map-get? documents { hash: hash }) (err u2))))
    (asserts! (is-eq tx-sender (get issuer doc)) (err u3))
    (map-set documents { hash: hash }
      (merge doc { title: new-title, revision: (+ (get revision doc) u1) }))
    (ok true)))

(define-read-only (get-document (hash (buff 32)))
  (map-get? documents { hash: hash }))

(define-read-only (is-active (hash (buff 32)))
  (match (map-get? documents { hash: hash })
    d (get active d)
    false))

(define-read-only (get-issuer-count (issuer principal))
  (default-to u0 (get count (map-get? issuer-counts { issuer: issuer }))))

(define-read-only (get-total-documents) (var-get total-documents))