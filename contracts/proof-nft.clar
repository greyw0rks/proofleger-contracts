;; proof-nft.clar
;; ProofLedger Proof Certificate NFT
;; SIP-009-compliant NFT issued on document anchoring

(define-non-fungible-token proof-cert uint)

(define-map token-metadata
  { token-id: uint }
  { owner: principal,
    hash: (buff 32),
    title: (string-ascii 100),
    doc-type: (string-ascii 50),
    minted-at: uint,
    network: (string-ascii 10) })

(define-data-var token-count uint u0)
(define-data-var contract-owner principal tx-sender)
(define-data-var minter principal tx-sender)

;; SIP-009 required functions

(define-read-only (get-last-token-id)
  (ok (var-get token-count)))

(define-read-only (get-token-uri (token-id uint))
  (ok (some (concat "https://verify.proofleger.vercel.app/cert/" (unwrap-panic (some (to-uint token-id)))))))

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? proof-cert token-id)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u401))
    (nft-transfer? proof-cert token-id sender recipient)))

;; mint: issue a certificate NFT upon successful anchor
;; Errors: u402 = not authorized minter
(define-public (mint (recipient principal) (hash (buff 32))
                      (title (string-ascii 100)) (doc-type (string-ascii 50)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get minter))
                  (is-eq tx-sender (var-get contract-owner))) (err u402))
    (let ((id (+ (var-get token-count) u1)))
      (try! (nft-mint? proof-cert id recipient))
      (map-set token-metadata { token-id: id }
        { owner:      recipient,
          hash:       hash,
          title:      title,
          doc-type:   doc-type,
          minted-at:  stacks-block-height,
          network:    "stacks" })
      (var-set token-count id)
      (ok id))))

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id }))

(define-read-only (get-tokens-by-owner-count (owner principal))
  ;; Approximate count via read-only — full index would require off-chain
  (var-get token-count))

(define-public (set-minter (new-minter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u401))
    (var-set minter new-minter)
    (ok true)))