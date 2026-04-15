;; proof-nft.clar
;; ProofLedger Transferable Proof NFT
;; Transferable NFTs representing document proof ownership
;; (unlike achievements which are soulbound)

(define-non-fungible-token proof-nft uint)
(define-data-var token-count uint u0)

(define-map token-data
  { token-id: uint }
  { hash: (buff 32), title: (string-ascii 100),
    doc-type: (string-ascii 50), minted-at: uint,
    original-owner: principal })

(define-map hash-to-token
  { hash: (buff 32) }
  { token-id: uint })

;; mint: create a transferable proof NFT
;; Errors: u1 = NFT already minted for this hash
(define-public (mint (hash (buff 32)) (title (string-ascii 100)) (doc-type (string-ascii 50)))
  (begin
    (asserts! (is-none (map-get? hash-to-token { hash: hash })) (err u1))
    (let ((id (+ (var-get token-count) u1)))
      (try! (nft-mint? proof-nft id tx-sender))
      (var-set token-count id)
      (map-set token-data { token-id: id }
        { hash: hash, title: title, doc-type: doc-type,
          minted-at: stacks-block-height, original-owner: tx-sender })
      (map-set hash-to-token { hash: hash } { token-id: id })
      (ok id))))

;; transfer: transfer NFT ownership (unlike achievements, this is allowed)
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u2))
    (try! (nft-transfer? proof-nft token-id sender recipient))
    (ok true)))

(define-read-only (get-owner (token-id uint))
  (nft-get-owner? proof-nft token-id))

(define-read-only (get-token-data (token-id uint))
  (map-get? token-data { token-id: token-id }))