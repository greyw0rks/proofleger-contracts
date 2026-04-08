;; reputation.clar
;; ProofLedger On-Chain Reputation
;; Stores computed reputation scores for public verification

(define-map reputation-scores
  { owner: principal }
  { score: uint, tier: (string-ascii 20), updated-at: uint })

(define-data-var total-scored uint u0)

;; set-reputation
;; Stores a reputation score for a wallet
(define-public (set-reputation (owner principal) (score uint) (tier (string-ascii 20)))
  (let ((is-new (is-none (map-get? reputation-scores { owner: owner }))))
    (map-set reputation-scores { owner: owner }
      { score: score, tier: tier, updated-at: stacks-block-height })
    (if is-new
      (var-set total-scored (+ (var-get total-scored) u1))
      true)
    (ok true)))

(define-read-only (get-reputation (owner principal))
  (map-get? reputation-scores { owner: owner }))

(define-read-only (get-total-scored)
  (var-get total-scored))