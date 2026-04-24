;; achievements.clar
;; ProofLedger Soulbound Achievements
;; Non-transferable NFTs awarded for protocol milestones

(define-non-fungible-token achievement uint)
(define-data-var token-count uint u0)

(define-map achievement-data
  { token-id: uint }
  { holder: principal, achievement-type: (string-ascii 50),
    document-hash: (buff 32), earned-at: uint })

(define-map holder-achievements
  { holder: principal, achievement-type: (string-ascii 50) }
  { token-id: uint })

(define-data-var contract-owner principal tx-sender)

;; mint: owner mints soulbound achievement for a holder
;; Errors: u401 = not owner, u1 = already has this achievement type
(define-public (mint (holder principal) (achievement-type (string-ascii 50))
                       (document-hash (buff 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u401))
    (asserts! (is-none (map-get? holder-achievements
      { holder: holder, achievement-type: achievement-type })) (err u1))
    (let ((id (+ (var-get token-count) u1)))
      (try! (nft-mint? achievement id holder))
      (var-set token-count id)
      (map-set achievement-data { token-id: id }
        { holder: holder, achievement-type: achievement-type,
          document-hash: document-hash, earned-at: stacks-block-height })
      (map-set holder-achievements { holder: holder, achievement-type: achievement-type }
        { token-id: id })
      (ok id))))

;; transfer blocked — soulbound
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (err u403))

(define-read-only (get-owner (token-id uint))
  (nft-get-owner? achievement token-id))

(define-read-only (has-achievement (holder principal) (achievement-type (string-ascii 50)))
  (is-some (map-get? holder-achievements { holder: holder, achievement-type: achievement-type })))

(define-read-only (get-achievement-data (token-id uint))
  (map-get? achievement-data { token-id: token-id }))

(define-read-only (get-total-minted) (var-get token-count))