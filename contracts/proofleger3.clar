(define-map documents { hash: (buff 32) } { owner: principal, block-height: uint, title: (string-ascii 100), doc-type: (string-ascii 50) })
(define-map wallet-docs { owner: principal, index: uint } { hash: (buff 32) })
(define-map wallet-count { owner: principal } { count: uint })

(define-public (store (hash (buff 32)) (title (string-ascii 100)) (doc-type (string-ascii 50)))
  (let ((existing (map-get? documents { hash: hash }))
        (count (default-to u0 (get count (map-get? wallet-count { owner: tx-sender })))))
    (asserts! (is-none existing) (err u1))
    (map-set documents { hash: hash } { owner: tx-sender, block-height: block-height, title: title, doc-type: doc-type })
    (map-set wallet-docs { owner: tx-sender, index: count } { hash: hash })
    (map-set wallet-count { owner: tx-sender } { count: (+ count u1) })
    (ok true)))

(define-read-only (get-doc (hash (buff 32)))
  (map-get? documents { hash: hash }))

(define-read-only (get-wallet-count (owner principal))
  (default-to u0 (get count (map-get? wallet-count { owner: owner }))))

(define-read-only (get-wallet-doc-at (owner principal) (index uint))
  (match (map-get? wallet-docs { owner: owner, index: index })
    entry (some (merge entry { hash: (get hash entry) }))
    none))
