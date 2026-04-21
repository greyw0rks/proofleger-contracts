;; badges.clar
;; ProofLedger Achievement Badges
;; Soulbound badges awarded for protocol milestones

(define-map badge-types
  { badge-id: (string-ascii 50) }
  { name: (string-ascii 100), description: (string-ascii 200),
    required-score: uint, created-at: uint })

(define-map earned-badges
  { holder: principal, badge-id: (string-ascii 50) }
  { earned-at: uint, score-at-earn: uint })

(define-data-var badge-admin principal tx-sender)

;; register-badge: admin creates a new badge type
(define-public (register-badge (badge-id (string-ascii 50)) (name (string-ascii 100))
                                 (description (string-ascii 200)) (required-score uint))
  (begin
    (asserts! (is-eq tx-sender (var-get badge-admin)) (err u401))
    (asserts! (is-none (map-get? badge-types { badge-id: badge-id })) (err u1))
    (map-set badge-types { badge-id: badge-id }
      { name: name, description: description,
        required-score: required-score, created-at: stacks-block-height })
    (ok true)))

;; award-badge: admin awards a badge to a wallet
;; Errors: u401 = not admin, u2 = badge not found, u3 = already has badge
(define-public (award-badge (holder principal) (badge-id (string-ascii 50)) (score uint))
  (begin
    (asserts! (is-eq tx-sender (var-get badge-admin)) (err u401))
    (asserts! (is-some (map-get? badge-types { badge-id: badge-id })) (err u2))
    (asserts! (is-none (map-get? earned-badges { holder: holder, badge-id: badge-id })) (err u3))
    (map-set earned-badges { holder: holder, badge-id: badge-id }
      { earned-at: stacks-block-height, score-at-earn: score })
    (ok true)))

(define-read-only (has-badge (holder principal) (badge-id (string-ascii 50)))
  (is-some (map-get? earned-badges { holder: holder, badge-id: badge-id })))

(define-read-only (get-badge-info (badge-id (string-ascii 50)))
  (map-get? badge-types { badge-id: badge-id }))