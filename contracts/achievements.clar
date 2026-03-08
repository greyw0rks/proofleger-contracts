(define-non-fungible-token achievement uint)
(define-data-var token-counter uint u0)

(define-map token-metadata { token-id: uint } { hash: (buff 32), achievement-type: (string-ascii 50), title: (string-ascii 100), minted-at: uint, owner: principal })
(define-map hash-to-token { hash: (buff 32), owner: principal } { token-id: uint })
(define-map owner-tokens { owner: principal, index: uint } { token-id: uint })
(define-map owner-token-count { owner: principal } { count: uint })

(define-public (mint (hash (buff 32)) (achievement-type (string-ascii 50)) (title (string-ascii 100)))
  (let ((existing (map-get? hash-to-token { hash: hash, owner: tx-sender }))
        (token-id (+ (var-get token-counter) u1))
        (count (default-to u0 (get count (map-get? owner-token-count { owner: tx-sender })))))
    (asserts! (is-none existing) (err u1))
    (try! (nft-mint? achievement token-id tx-sender))
    (var-set token-counter token-id)
    (map-set token-metadata { token-id: token-id } { hash: hash, achievement-type: achievement-type, title: title, minted-at: block-height, owner: tx-sender })
    (map-set hash-to-token { hash: hash, owner: tx-sender } { token-id: token-id })
    (map-set owner-tokens { owner: tx-sender, index: count } { token-id: token-id })
    (map-set owner-token-count { owner: tx-sender } { count: (+ count u1) })
    (ok token-id)))

(define-read-only (get-token-by-hash (hash (buff 32)) (owner principal))
  (map-get? hash-to-token { hash: hash, owner: owner }))

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id }))

(define-read-only (get-owner-token-count (owner principal))
  (default-to u0 (get count (map-get? owner-token-count { owner: owner }))))

(define-read-only (get-owner-token-at (owner principal) (index uint))
  (map-get? owner-tokens { owner: owner, index: index }))

(define-read-only (get-last-token-id)
  (ok (var-get token-counter)))

(define-read-only (get-token-uri (token-id uint))
  (ok none))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? achievement token-id)))
