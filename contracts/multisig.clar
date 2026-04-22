;; multisig.clar
;; ProofLedger Multi-Signature Approval
;; Require m-of-n signers to approve a transaction or action

(define-map multisig-configs
  { wallet-id: uint }
  { owners: (list 10 principal), threshold: uint,
    created-at: uint, active: bool })

(define-map proposals
  { wallet-id: uint, proposal-id: uint }
  { action: (string-ascii 200), proposed-by: principal,
    proposed-at: uint, executed: bool,
    approval-count: uint })

(define-map approvals
  { wallet-id: uint, proposal-id: uint, approver: principal }
  { approved-at: uint })

(define-map proposal-counts
  { wallet-id: uint }
  { count: uint })

(define-data-var wallet-count uint u0)

;; create-multisig: deploy a new m-of-n wallet
;; Errors: u1 = threshold exceeds owner count, u2 = no owners
(define-public (create-multisig (owners (list 10 principal)) (threshold uint))
  (let ((n (len owners))
        (id (+ (var-get wallet-count) u1)))
    (asserts! (> n u0) (err u2))
    (asserts! (<= threshold n) (err u1))
    (map-set multisig-configs { wallet-id: id }
      { owners: owners, threshold: threshold,
        created-at: stacks-block-height, active: true })
    (var-set wallet-count id)
    (ok id)))

;; propose: owner submits a proposal
;; Errors: u3 = wallet not found, u4 = not an owner
(define-public (propose (wallet-id uint) (action (string-ascii 200)))
  (let ((config (unwrap! (map-get? multisig-configs { wallet-id: wallet-id }) (err u3)))
        (count  (default-to u0 (get count (map-get? proposal-counts { wallet-id: wallet-id })))))
    (asserts! (is-some (index-of (get owners config) tx-sender)) (err u4))
    (let ((pid (+ count u1)))
      (map-set proposals { wallet-id: wallet-id, proposal-id: pid }
        { action: action, proposed-by: tx-sender,
          proposed-at: stacks-block-height, executed: false, approval-count: u0 })
      (map-set proposal-counts { wallet-id: wallet-id } { count: pid })
      (ok pid))))

;; approve: owner approves a proposal
;; Errors: u5 = proposal not found, u6 = already approved
(define-public (approve (wallet-id uint) (proposal-id uint))
  (let ((config (unwrap! (map-get? multisig-configs { wallet-id: wallet-id }) (err u3)))
        (prop   (unwrap! (map-get? proposals { wallet-id: wallet-id, proposal-id: proposal-id }) (err u5))))
    (asserts! (is-some (index-of (get owners config) tx-sender)) (err u4))
    (asserts! (is-none (map-get? approvals { wallet-id: wallet-id, proposal-id: proposal-id, approver: tx-sender })) (err u6))
    (map-set approvals { wallet-id: wallet-id, proposal-id: proposal-id, approver: tx-sender }
      { approved-at: stacks-block-height })
    (map-set proposals { wallet-id: wallet-id, proposal-id: proposal-id }
      (merge prop { approval-count: (+ (get approval-count prop) u1) }))
    (ok (+ (get approval-count prop) u1))))

(define-read-only (is-approved (wallet-id uint) (proposal-id uint))
  (match (map-get? proposals { wallet-id: wallet-id, proposal-id: proposal-id })
    p (match (map-get? multisig-configs { wallet-id: wallet-id })
        c (>= (get approval-count p) (get threshold c))
        false)
    false))

(define-read-only (get-proposal (wallet-id uint) (proposal-id uint))
  (map-get? proposals { wallet-id: wallet-id, proposal-id: proposal-id }))