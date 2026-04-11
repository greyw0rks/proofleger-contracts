;; achievements-v2.clar
;; ProofLedger Achievement NFTs v2
;; Extended soulbound NFT with external metadata URI and categories

(define-non-fungible-token achievement-v2 uint)
(define-data-var token-counter uint u0)

(define-map token-metadata
  { token-id: uint }
  { hash: (buff 32), achievement-type: (string-ascii 50),
    title: (string-ascii 100), minted-at: uint, owner: principal,
    metadata-uri: (string-ascii 256), category: (string-ascii 30) })

(define-map hash-to-token
  { hash: (buff 32), owner: principal }
  { token-id: uint })

(define-map owner-token-count
  { owner: principal }
  { count: uint })

;; mint: mint soulbound achievement with optional metadata URI
;; Errors: u1 = already minted for this hash
(define-public (mint (hash (buff 32)) (achievement-type (string-ascii 50))
                     (title (string-ascii 100)) (metadata-uri (string-ascii 256))
                     (category (string-ascii 30)))
  (let ((existing (map-get? hash-to-token { hash: hash, owner: tx-sender }))
        (token-id (+ (var-get token-counter) u1))
        (count (default-to u0 (get count (map-get? owner-token-count { owner: tx-sender })))))
    (asserts! (is-none existing) (err u1))
    (try! (nft-mint? achievement-v2 token-id tx-sender))
    (var-set token-counter token-id)
    (map-set token-metadata { token-id: token-id }
      { hash: hash, achievement-type: achievement-type, title: title,
        minted-at: stacks-block-height, owner: tx-sender,
        metadata-uri: metadata-uri, category: category })
    (map-set hash-to-token { hash: hash, owner: tx-sender } { token-id: token-id })
    (map-set owner-token-count { owner: tx-sender } { count: (+ count u1) })
    (ok token-id)))

;; transfer is always blocked — achievements are soulbound
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (err u500))

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id }))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? achievement-v2 token-id)))

(define-read-only (get-last-token-id)
  (ok (var-get token-counter)))