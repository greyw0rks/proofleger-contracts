;; recovery.clar
;; ProofLedger Social Recovery
;; Allow a principal to designate guardians who can restore access

(define-map recovery-configs
  { owner: principal }
  { guardian-1:  principal,
    guardian-2:  principal,
    threshold:   uint,       ;; 1 or 2 guardians required
    locked-at:   uint,
    new-owner:   (optional principal),
    approvals:   uint })

(define-map guardian-approvals
  { owner: principal, guardian: principal }
  { approved-at: uint, new-owner: principal })

(define-data-var recovery-admin principal tx-sender)

;; setup-recovery: owner registers two guardians and a threshold
;; Errors: u1 = already configured
(define-public (setup-recovery (g1 principal) (g2 principal) (threshold uint))
  (begin
    (asserts! (is-none (map-get? recovery-configs { owner: tx-sender })) (err u1))
    (asserts! (or (is-eq threshold u1) (is-eq threshold u2)) (err u2))
    (map-set recovery-configs { owner: tx-sender }
      { guardian-1: g1, guardian-2: g2, threshold: threshold,
        locked-at: u0, new-owner: none, approvals: u0 })
    (ok true)))

;; initiate-recovery: guardian proposes a new owner address
;; Errors: u3 = not a guardian, u4 = recovery not configured
(define-public (initiate-recovery (owner principal) (new-owner principal))
  (let ((config (unwrap! (map-get? recovery-configs { owner: owner }) (err u4))))
    (asserts! (or (is-eq tx-sender (get guardian-1 config))
                  (is-eq tx-sender (get guardian-2 config))) (err u3))
    (map-set guardian-approvals { owner: owner, guardian: tx-sender }
      { approved-at: stacks-block-height, new-owner: new-owner })
    (let ((approvals (+ (get approvals config) u1)))
      (map-set recovery-configs { owner: owner }
        (merge config { approvals: approvals, new-owner: (some new-owner) }))
      (ok approvals))))

;; finalize-recovery: once threshold met, lock is lifted for new-owner
;; Errors: u4 = not configured, u5 = threshold not met
(define-public (finalize-recovery (owner principal))
  (let ((config (unwrap! (map-get? recovery-configs { owner: owner }) (err u4))))
    (asserts! (>= (get approvals config) (get threshold config)) (err u5))
    (map-set recovery-configs { owner: owner }
      (merge config { locked-at: stacks-block-height }))
    (ok (get new-owner config))))

(define-read-only (get-recovery-config (owner principal))
  (map-get? recovery-configs { owner: owner }))

(define-read-only (get-approvals (owner principal))
  (default-to u0 (get approvals (map-get? recovery-configs { owner: owner }))))