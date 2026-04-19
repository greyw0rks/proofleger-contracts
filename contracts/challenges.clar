;; challenges.clar
;; ProofLedger Skill Challenges
;; Issue challenges that require proof submission for completion

(define-map challenges
  { id: uint }
  { creator: principal, title: (string-ascii 100),
    challenge-type: (string-ascii 50), reward-amount: uint,
    deadline: uint, active: bool, winner: (optional principal),
    submission-count: uint, created-at: uint })

(define-map submissions
  { challenge-id: uint, submitter: principal }
  { proof-hash: (buff 32), submitted-at: uint, accepted: bool })

(define-data-var challenge-count uint u0)

;; create-challenge: create a challenge with optional STX reward
(define-public (create-challenge (title (string-ascii 100))
                                   (challenge-type (string-ascii 50))
                                   (deadline uint) (reward uint))
  (let ((id (+ (var-get challenge-count) u1)))
    (when (> reward u0) (try! (stx-transfer? reward tx-sender (as-contract tx-sender))))
    (map-set challenges { id: id }
      { creator: tx-sender, title: title, challenge-type: challenge-type,
        reward-amount: reward, deadline: deadline, active: true,
        winner: none, submission-count: u0, created-at: stacks-block-height })
    (var-set challenge-count id)
    (ok id)))

;; submit-proof: challenger submits a proof hash
;; Errors: u1 = not found, u2 = not active, u3 = past deadline, u4 = already submitted
(define-public (submit-proof (challenge-id uint) (proof-hash (buff 32)))
  (let ((c (unwrap! (map-get? challenges { id: challenge-id }) (err u1))))
    (asserts! (get active c) (err u2))
    (asserts! (<= stacks-block-height (get deadline c)) (err u3))
    (asserts! (is-none (map-get? submissions { challenge-id: challenge-id, submitter: tx-sender })) (err u4))
    (map-set submissions { challenge-id: challenge-id, submitter: tx-sender }
      { proof-hash: proof-hash, submitted-at: stacks-block-height, accepted: false })
    (map-set challenges { id: challenge-id }
      (merge c { submission-count: (+ (get submission-count c) u1) }))
    (ok true)))

;; accept-submission: creator accepts a submission and awards winner
;; Errors: u5 = not creator, u6 = submission not found
(define-public (accept-submission (challenge-id uint) (winner principal))
  (let ((c (unwrap! (map-get? challenges { id: challenge-id }) (err u1)))
        (sub (unwrap! (map-get? submissions { challenge-id: challenge-id, submitter: winner }) (err u6))))
    (asserts! (is-eq tx-sender (get creator c)) (err u5))
    (when (> (get reward-amount c) u0)
      (try! (as-contract (stx-transfer? (get reward-amount c) tx-sender winner))))
    (map-set submissions { challenge-id: challenge-id, submitter: winner }
      (merge sub { accepted: true }))
    (map-set challenges { id: challenge-id }
      (merge c { active: false, winner: (some winner) }))
    (ok true)))

(define-read-only (get-challenge (id uint))
  (map-get? challenges { id: id }))

(define-read-only (get-submission (challenge-id uint) (submitter principal))
  (map-get? submissions { challenge-id: challenge-id, submitter: submitter }))