;; governance.clar
;; ProofLedger Governance
;; Stake-weighted proposals — any staker may submit and vote

(define-map proposals
  { proposal-id: uint }
  { title:        (string-ascii 100),
    description:  (string-ascii 300),
    proposer:     principal,
    votes-for:    uint,
    votes-against: uint,
    created-at:   uint,
    closes-at:    uint,
    executed:     bool,
    passed:       bool })

(define-map votes
  { proposal-id: uint, voter: principal }
  { weight:      uint,
    in-favor:    bool,
    voted-at:    uint })

(define-data-var gov-admin      principal tx-sender)
(define-data-var proposal-count uint u0)
(define-data-var vote-window    uint u288)  ;; ~2 days in blocks
(define-data-var pass-threshold uint u60)   ;; 60% to pass

;; propose: any principal may create a proposal
(define-public (propose (title (string-ascii 100))
                         (description (string-ascii 300)))
  (let ((id (+ (var-get proposal-count) u1)))
    (map-set proposals { proposal-id: id }
      { title:          title,
        description:    description,
        proposer:       tx-sender,
        votes-for:      u0,
        votes-against:  u0,
        created-at:     stacks-block-height,
        closes-at:      (+ stacks-block-height (var-get vote-window)),
        executed:       false,
        passed:         false })
    (var-set proposal-count id)
    (ok id)))

;; vote: cast a weighted vote — weight passed in by caller (from staking contract)
;; Errors: u1 = not found, u2 = voting closed, u3 = already voted
(define-public (vote (proposal-id uint) (weight uint) (in-favor bool))
  (let ((p (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u1))))
    (asserts! (<= stacks-block-height (get closes-at p)) (err u2))
    (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: tx-sender })) (err u3))
    (asserts! (> weight u0) (err u4))
    (map-set votes { proposal-id: proposal-id, voter: tx-sender }
      { weight: weight, in-favor: in-favor, voted-at: stacks-block-height })
    (map-set proposals { proposal-id: proposal-id }
      (merge p {
        votes-for:     (if in-favor (+ (get votes-for p) weight) (get votes-for p)),
        votes-against: (if in-favor (get votes-against p) (+ (get votes-against p) weight))
      }))
    (ok true)))

;; finalize: admin marks proposal passed/failed after close
;; Errors: u1 = not found, u5 = voting still open, u6 = not admin
(define-public (finalize (proposal-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get gov-admin)) (err u6))
    (let ((p (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u1))))
      (asserts! (> stacks-block-height (get closes-at p)) (err u5))
      (let* ((total (+ (get votes-for p) (get votes-against p)))
             (pct   (if (> total u0) (/ (* (get votes-for p) u100) total) u0))
             (pass  (>= pct (var-get pass-threshold))))
        (map-set proposals { proposal-id: proposal-id }
          (merge p { executed: true, passed: pass }))
        (ok pass)))))

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id }))

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter }))

(define-read-only (get-proposal-count) (var-get proposal-count))