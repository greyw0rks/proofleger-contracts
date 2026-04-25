;; credential-schema.clar
;; ProofLedger Credential Schema Registry
;; Issuers publish reusable credential templates; holders reference schema-id

(define-map schemas
  { schema-id: uint }
  { name:        (string-ascii 80),
    version:     (string-ascii 10),
    issuer:      principal,
    fields:      (string-ascii 200), ;; JSON field spec stored as ASCII
    created-at:  uint,
    deprecated:  bool })

(define-map schema-usage
  { schema-id: uint }
  { count: uint })

(define-data-var schema-count uint u0)

;; publish-schema: issuer registers a new credential template
(define-public (publish-schema (name (string-ascii 80))
                                 (version (string-ascii 10))
                                 (fields (string-ascii 200)))
  (let ((id (+ (var-get schema-count) u1)))
    (map-set schemas { schema-id: id }
      { name:       name,
        version:    version,
        issuer:     tx-sender,
        fields:     fields,
        created-at: stacks-block-height,
        deprecated: false })
    (var-set schema-count id)
    (ok id)))

;; deprecate-schema: issuer marks a schema as no longer recommended
;; Errors: u1 = not found, u2 = not issuer
(define-public (deprecate-schema (schema-id uint))
  (let ((s (unwrap! (map-get? schemas { schema-id: schema-id }) (err u1))))
    (asserts! (is-eq tx-sender (get issuer s)) (err u2))
    (map-set schemas { schema-id: schema-id }
      (merge s { deprecated: true }))
    (ok true)))

;; record-usage: called when a credential is issued against this schema
(define-public (record-usage (schema-id uint))
  (begin
    (asserts! (is-some (map-get? schemas { schema-id: schema-id })) (err u1))
    (let ((cur (default-to u0 (get count (map-get? schema-usage { schema-id: schema-id })))))
      (map-set schema-usage { schema-id: schema-id } { count: (+ cur u1) }))
    (ok true)))

(define-read-only (get-schema (schema-id uint))
  (map-get? schemas { schema-id: schema-id }))

(define-read-only (get-schema-usage (schema-id uint))
  (default-to u0 (get count (map-get? schema-usage { schema-id: schema-id }))))

(define-read-only (get-schema-count) (var-get schema-count))