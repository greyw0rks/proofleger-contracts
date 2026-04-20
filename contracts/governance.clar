;; governance.clar
;; ProofLedger Protocol Governance
;; On-chain proposals and voting for protocol changes

(define-map proposals
  { id: uint }
  { proposer: principal, title: (string-ascii 100),
    description: (string-ascii 500), action: (string-ascii 200),
    votes-for: uint, votes-against: uint,
    start-block: uint, end-block: uint,
    executed: bool, passed: bool })

(define-map votes
  { proposal-id: uint, voter: principal }
  { support: bool, voted-at: uint })

(define-data-var proposal-count uint u0)
(define-data-var quorum uint u10)
(define-data-var voting-period uint u1440) ;; ~10 days

;; propose: submit a governance proposal
(define-public (propose (title (string-ascii 100)) (description (string-ascii 500))
                          (action (string-ascii 200)))
  (let ((id (+ (var-get proposal-count) u1)))
    (map-set proposals { id: id }
      { proposer: tx-sender, title: title, description: description, action: action,
        votes-for: u0, votes-against: u0,
        start-block: stacks-block-height,
        end-block: (+ stacks-block-height (var-get voting-period)),
        executed: false, passed: false })
    (var-set proposal-count id)
    (ok id)))

;; vote: cast a vote on an active proposal
;; Errors: u1 = not found, u2 = voting closed, u3 = already voted
(define-public (vote (proposal-id uint) (support bool))
  (let ((p (unwrap! (map-get? proposals { id: proposal-id }) (err u1))))
    (asserts! (<= stacks-block-height (get end-block p)) (err u2))
    (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: tx-sender })) (err u3))
    (map-set votes { proposal-id: proposal-id, voter: tx-sender }
      { support: support, voted-at: stacks-block-height })
    (map-set proposals { id: proposal-id }
      (if support
        (merge p { votes-for: (+ (get votes-for p) u1) })
        (merge p { votes-against: (+ (get votes-against p) u1) })))
    (ok true)))

(define-read-only (get-proposal (id uint))
  (map-get? proposals { id: id }))

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter }))

(define-read-only (has-quorum (id uint))
  (match (map-get? proposals { id: id })
    p (>= (+ (get votes-for p) (get votes-against p)) (var-get quorum))
    false))