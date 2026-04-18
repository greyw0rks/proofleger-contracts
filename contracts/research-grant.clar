;; research-grant.clar
;; ProofLedger Research Grant Management
;; Manage research grants with milestone-based fund release

(define-map grants
  { grant-id: uint }
  { grantor: principal, grantee: principal,
    title: (string-ascii 100), total-amount: uint,
    released-amount: uint, milestone-count: uint,
    created-at: uint, active: bool })

(define-map milestones
  { grant-id: uint, index: uint }
  { description: (string-ascii 200), amount: uint,
    proof-hash: (optional (buff 32)), completed: bool,
    completed-at: (optional uint) })

(define-data-var grant-count uint u0)

;; create-grant: grantor creates a research grant
(define-public (create-grant (grantee principal) (title (string-ascii 100)) (amount uint))
  (let ((id (+ (var-get grant-count) u1)))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set grants { grant-id: id }
      { grantor: tx-sender, grantee: grantee, title: title,
        total-amount: amount, released-amount: u0,
        milestone-count: u0, created-at: stacks-block-height, active: true })
    (var-set grant-count id)
    (ok id)))

;; add-milestone: grantor adds a milestone with partial fund release amount
;; Errors: u1 = not found, u2 = not grantor
(define-public (add-milestone (grant-id uint) (description (string-ascii 200)) (amount uint))
  (let ((grant (unwrap! (map-get? grants { grant-id: grant-id }) (err u1)))
        (idx (get milestone-count grant)))
    (asserts! (is-eq tx-sender (get grantor grant)) (err u2))
    (map-set milestones { grant-id: grant-id, index: idx }
      { description: description, amount: amount,
        proof-hash: none, completed: false, completed-at: none })
    (map-set grants { grant-id: grant-id }
      (merge grant { milestone-count: (+ idx u1) }))
    (ok idx)))

;; complete-milestone: grantee submits proof and claims milestone funds
;; Errors: u3 = milestone not found, u4 = not grantee, u5 = already completed
(define-public (complete-milestone (grant-id uint) (milestone-idx uint) (proof-hash (buff 32)))
  (let ((grant (unwrap! (map-get? grants { grant-id: grant-id }) (err u1)))
        (ms (unwrap! (map-get? milestones { grant-id: grant-id, index: milestone-idx }) (err u3))))
    (asserts! (is-eq tx-sender (get grantee grant)) (err u4))
    (asserts! (not (get completed ms)) (err u5))
    (try! (as-contract (stx-transfer? (get amount ms) tx-sender (get grantee grant))))
    (map-set milestones { grant-id: grant-id, index: milestone-idx }
      (merge ms { completed: true, proof-hash: (some proof-hash),
                  completed-at: (some stacks-block-height) }))
    (map-set grants { grant-id: grant-id }
      (merge grant { released-amount: (+ (get released-amount grant) (get amount ms)) }))
    (ok true)))

(define-read-only (get-grant (grant-id uint))
  (map-get? grants { grant-id: grant-id }))

(define-read-only (get-milestone (grant-id uint) (index uint))
  (map-get? milestones { grant-id: grant-id, index: index }))