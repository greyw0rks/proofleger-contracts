;; collections.clar
;; ProofLedger Document Collections
;; Group related documents into named, shareable collections

(define-map collections
  { id: uint }
  { owner: principal, name: (string-ascii 100),
    description: (string-ascii 200), doc-count: uint,
    created-at: uint, public: bool })

(define-map collection-docs
  { collection-id: uint, index: uint }
  { hash: (buff 32), added-at: uint })

(define-map hash-to-collection
  { hash: (buff 32), collection-id: uint }
  { index: uint })

(define-data-var collection-count uint u0)

;; create-collection: owner creates a named collection
(define-public (create-collection (name (string-ascii 100))
                                    (description (string-ascii 200))
                                    (public bool))
  (let ((id (+ (var-get collection-count) u1)))
    (map-set collections { id: id }
      { owner: tx-sender, name: name, description: description,
        doc-count: u0, created-at: stacks-block-height, public: public })
    (var-set collection-count id)
    (ok id)))

;; add-doc: owner adds a document hash to their collection
;; Errors: u1 = not found, u2 = not owner, u3 = already in collection
(define-public (add-doc (collection-id uint) (hash (buff 32)))
  (let ((col (unwrap! (map-get? collections { id: collection-id }) (err u1)))
        (idx (get doc-count (unwrap! (map-get? collections { id: collection-id }) (err u1)))))
    (asserts! (is-eq tx-sender (get owner col)) (err u2))
    (asserts! (is-none (map-get? hash-to-collection
      { hash: hash, collection-id: collection-id })) (err u3))
    (map-set collection-docs { collection-id: collection-id, index: idx }
      { hash: hash, added-at: stacks-block-height })
    (map-set hash-to-collection { hash: hash, collection-id: collection-id }
      { index: idx })
    (map-set collections { id: collection-id }
      (merge col { doc-count: (+ idx u1) }))
    (ok idx)))

(define-read-only (get-collection (id uint))
  (map-get? collections { id: id }))

(define-read-only (get-doc-at (collection-id uint) (index uint))
  (map-get? collection-docs { collection-id: collection-id, index: index }))

(define-read-only (get-collection-count) (var-get collection-count))