;; collections.clar
;; ProofLedger Document Collections
;; Group multiple document hashes into named, owned collections

(define-map collections
  { owner: principal, name: (string-ascii 100) }
  { created-at: uint, count: uint, description: (string-ascii 200) })

(define-map collection-items
  { owner: principal, name: (string-ascii 100), index: uint }
  { hash: (buff 32) })

;; create-collection: create a new named collection
;; Errors: u1 = already exists
(define-public (create-collection (name (string-ascii 100)) (description (string-ascii 200)))
  (begin
    (asserts! (is-none (map-get? collections { owner: tx-sender, name: name })) (err u1))
    (map-set collections { owner: tx-sender, name: name }
      { created-at: stacks-block-height, count: u0, description: description })
    (ok true)))

;; add-to-collection: add a document hash to an existing collection
;; Errors: u2 = collection not found
(define-public (add-to-collection (name (string-ascii 100)) (hash (buff 32)))
  (let ((col (unwrap! (map-get? collections { owner: tx-sender, name: name }) (err u2)))
        (idx (get count col)))
    (map-set collection-items { owner: tx-sender, name: name, index: idx } { hash: hash })
    (map-set collections { owner: tx-sender, name: name } (merge col { count: (+ idx u1) }))
    (ok true)))

(define-read-only (get-collection (owner principal) (name (string-ascii 100)))
  (map-get? collections { owner: owner, name: name }))

(define-read-only (get-item (owner principal) (name (string-ascii 100)) (index uint))
  (map-get? collection-items { owner: owner, name: name, index: index }))