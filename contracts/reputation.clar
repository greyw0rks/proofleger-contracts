;; reputation.clar
;; ProofLedger Reputation System
;; Aggregate on-chain activity into a reputation score per wallet

(define-map reputation-scores
  { principal: principal }
  { score: uint, anchors: uint, attests: uint,
    endorsements: uint, nfts: uint, last-updated: uint })

(define-data-var contract-owner principal tx-sender)

(define-read-only (get-score (user principal))
  (default-to u0 (get score (map-get? reputation-scores { principal: user }))))

(define-read-only (get-reputation (user principal))
  (map-get? reputation-scores { principal: user }))

;; update-score: authorized callers submit activity deltas
;; Errors: u401 = not authorized
(define-public (record-anchor (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u401))
    (let ((r (default-to { score:u0, anchors:u0, attests:u0, endorsements:u0, nfts:u0, last-updated:u0 }
               (map-get? reputation-scores { principal: user }))))
      (map-set reputation-scores { principal: user }
        (merge r { anchors: (+ (get anchors r) u1),
                   score: (+ (get score r) u10),
                   last-updated: stacks-block-height }))
      (ok true))))

(define-public (record-attest (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u401))
    (let ((r (default-to { score:u0, anchors:u0, attests:u0, endorsements:u0, nfts:u0, last-updated:u0 }
               (map-get? reputation-scores { principal: user }))))
      (map-set reputation-scores { principal: user }
        (merge r { attests: (+ (get attests r) u1),
                   score: (+ (get score r) u5),
                   last-updated: stacks-block-height }))
      (ok true))))

(define-public (record-nft (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u401))
    (let ((r (default-to { score:u0, anchors:u0, attests:u0, endorsements:u0, nfts:u0, last-updated:u0 }
               (map-get? reputation-scores { principal: user }))))
      (map-set reputation-scores { principal: user }
        (merge r { nfts: (+ (get nfts r) u1),
                   score: (+ (get score r) u25),
                   last-updated: stacks-block-height }))
      (ok true))))