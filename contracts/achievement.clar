;; achievement.clar
;; ProofLedger Achievement System
;; Award on-chain badges for reaching proof milestones

(define-map achievements
  { achievement-id: uint }
  { name:        (string-ascii 60),
    description: (string-ascii 150),
    threshold:   uint,           ;; number of actions required
    action-type: (string-ascii 20) }) ;; anchor | attest | verify | stake

(define-map user-achievements
  { holder: principal, achievement-id: uint }
  { earned-at: uint, count-at-earn: uint })

(define-data-var achieve-admin principal tx-sender)
(define-data-var achieve-count uint u0)

;; define-achievement: admin creates a new milestone badge
;; Errors: u401 = not admin
(define-public (define-achievement (name        (string-ascii 60))
                                     (description (string-ascii 150))
                                     (threshold   uint)
                                     (action-type (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get achieve-admin)) (err u401))
    (let ((id (+ (var-get achieve-count) u1)))
      (map-set achievements { achievement-id: id }
        { name: name, description: description,
          threshold: threshold, action-type: action-type })
      (var-set achieve-count id)
      (ok id))))

;; award: admin awards an achievement to a holder
;; Errors: u401 = not admin, u1 = achievement not found, u2 = already earned
(define-public (award (holder principal) (achievement-id uint) (count-at-earn uint))
  (begin
    (asserts! (is-eq tx-sender (var-get achieve-admin)) (err u401))
    (asserts! (is-some (map-get? achievements { achievement-id: achievement-id })) (err u1))
    (asserts! (is-none (map-get? user-achievements
      { holder: holder, achievement-id: achievement-id })) (err u2))
    (map-set user-achievements { holder: holder, achievement-id: achievement-id }
      { earned-at: stacks-block-height, count-at-earn: count-at-earn })
    (ok true)))

(define-read-only (has-achievement (holder principal) (achievement-id uint))
  (is-some (map-get? user-achievements { holder: holder, achievement-id: achievement-id })))

(define-read-only (get-achievement (achievement-id uint))
  (map-get? achievements { achievement-id: achievement-id }))

(define-read-only (get-achievement-count) (var-get achieve-count))