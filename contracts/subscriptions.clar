;; subscriptions.clar
;; ProofLedger Subscription Tiers
;; Monthly subscription plans unlocking pro features

(define-map subscriptions
  { subscriber: principal }
  { tier: (string-ascii 20), expires-at: uint,
    started-at: uint, total-paid: uint })

(define-map tier-config
  { tier: (string-ascii 20) }
  { price: uint, duration: uint, active: bool })

(define-data-var contract-owner principal tx-sender)
(define-data-var total-subscribers uint u0)

;; init default tiers at deploy
(map-set tier-config { tier: "basic" }    { price: u5000000,  duration: u4320, active: true })   ;; 5 STX/month
(map-set tier-config { tier: "pro" }      { price: u15000000, duration: u4320, active: true })   ;; 15 STX/month
(map-set tier-config { tier: "enterprise"}{ price: u50000000, duration: u4320, active: true })   ;; 50 STX/month

;; subscribe: pay STX to activate subscription tier
;; Errors: u1 = tier not found, u2 = tier not active
(define-public (subscribe (tier (string-ascii 20)))
  (let ((config (unwrap! (map-get? tier-config { tier: tier }) (err u1))))
    (asserts! (get active config) (err u2))
    (try! (stx-transfer? (get price config) tx-sender (as-contract tx-sender)))
    (let ((existing (map-get? subscriptions { subscriber: tx-sender }))
          (start (default-to stacks-block-height (match existing e (get expires-at e) none))))
      (when (is-none existing) (var-set total-subscribers (+ (var-get total-subscribers) u1)))
      (map-set subscriptions { subscriber: tx-sender }
        { tier: tier, expires-at: (+ start (get duration config)),
          started-at: stacks-block-height,
          total-paid: (+ (default-to u0 (get total-paid existing)) (get price config)) }))
    (ok true)))

(define-read-only (is-subscribed (user principal))
  (match (map-get? subscriptions { subscriber: user })
    s (and (<= stacks-block-height (get expires-at s)))
    false))

(define-read-only (get-subscription (user principal))
  (map-get? subscriptions { subscriber: user }))

(define-read-only (get-tier-config (tier (string-ascii 20)))
  (map-get? tier-config { tier: tier }))