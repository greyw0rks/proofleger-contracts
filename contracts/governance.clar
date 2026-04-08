;; governance.clar
;; ProofLedger On-Chain Governance
;; Community proposals and voting

(define-map proposals
  { id: uint }
  { creator: principal, title: (string-ascii 100), description: (string-ascii 500),
    yes-votes: uint, no-votes: uint, created-at: uint, active: bool })

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool, voted-at: uint })

(define-data-var proposal-count uint u0)

;; create-proposal: open a new governance proposal
(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)))
  (let ((id (+ (var-get proposal-count) u1)))
    (map-set proposals { id: id }
      { creator: tx-sender, title: title, description: description,
        yes-votes: u0, no-votes: u0, created-at: stacks-block-height, active: true })
    (var-set proposal-count id)
    (ok id)))

;; vote: cast a yes or no vote on an active proposal
;; Errors: u1 = not found, u2 = closed, u3 = already voted
(define-public (vote (proposal-id uint) (support bool))
  (let ((p (unwrap! (map-get? proposals { id: proposal-id }) (err u1))))
    (asserts! (get active p) (err u2))
    (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: tx-sender })) (err u3))
    (map-set votes { proposal-id: proposal-id, voter: tx-sender }
      { vote: support, voted-at: stacks-block-height })
    (map-set proposals { id: proposal-id }
      (if support
        (merge p { yes-votes: (+ (get yes-votes p) u1) })
        (merge p { no-votes: (+ (get no-votes p) u1) })))
    (ok true)))

(define-read-only (get-proposal (id uint))
  (map-get? proposals { id: id }))

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter }))