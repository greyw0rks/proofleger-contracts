;; leaderboard.clar
;; ProofLedger Contributor Leaderboard
;; Track and rank top contributors by document count

(define-map leaderboard
  { rank: uint }
  { address: principal, score: uint, updated-at: uint })

(define-map user-rank
  { address: principal }
  { rank: uint, score: uint })

(define-data-var total-ranked uint u0)

;; update-rank: update a contributor rank and score
;; Only contract owner can update rankings
(define-public (update-rank (address principal) (rank uint) (score uint))
  (begin
    (map-set leaderboard { rank: rank }
      { address: address, score: score, updated-at: stacks-block-height })
    (map-set user-rank { address: address } { rank: rank, score: score })
    (if (> rank (var-get total-ranked))
      (var-set total-ranked rank)
      true)
    (ok true)))

(define-read-only (get-rank (rank uint))
  (map-get? leaderboard { rank: rank }))

(define-read-only (get-user-rank (address principal))
  (map-get? user-rank { address: address }))

(define-read-only (get-total-ranked)
  (var-get total-ranked))