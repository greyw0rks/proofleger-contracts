;; subscription-v2.clar
;; ProofLedger Subscription v2
;; Three-tier subscription: free / pro / enterprise

(define-map subscriptions
  { subscriber: principal }
  { tier:        (string-ascii 10),  ;; free | pro | enterprise
    paid-at:     uint,
    expires-at:  uint,
    auto-renew:  bool })

(define-map tier-prices
  { tier: (string-ascii 10) }
  { price-ustx:  uint,
    duration:    uint })   ;; duration in blocks

(define-data-var sub-admin   principal tx-sender)
(define-data-var sub-treasury principal tx-sender)

;; Seed tier prices (~$5 pro, ~$25 enterprise at ~$0.10/STX)
(map-set tier-prices { tier: "pro"        } { price-ustx: u50000000,  duration: u4320 })  ;; ~30 days
(map-set tier-prices { tier: "enterprise" } { price-ustx: u250000000, duration: u4320 })

;; subscribe: purchase a subscription tier
;; Errors: u1 = invalid tier, u2 = payment failed
(define-public (subscribe (tier (string-ascii 10)))
  (let ((price (unwrap! (map-get? tier-prices { tier: tier }) (err u1))))
    (try! (stx-transfer? (get price-ustx price) tx-sender (var-get sub-treasury)))
    (let ((expires (+ stacks-block-height (get duration price))))
      (map-set subscriptions { subscriber: tx-sender }
        { tier: tier, paid-at: stacks-block-height,
          expires-at: expires, auto-renew: false })
      (ok expires))))

;; is-active: returns true if the caller has an active subscription at tier or above
(define-read-only (is-active (subscriber principal) (min-tier (string-ascii 10)))
  (match (map-get? subscriptions { subscriber: subscriber })
    s (and
        (< stacks-block-height (get expires-at s))
        (or (is-eq min-tier "free")
            (and (is-eq min-tier "pro")
                 (or (is-eq (get tier s) "pro")
                     (is-eq (get tier s) "enterprise")))
            (is-eq min-tier (get tier s))))
    (is-eq min-tier "free")))

(define-read-only (get-subscription (subscriber principal))
  (map-get? subscriptions { subscriber: subscriber }))

(define-read-only (get-tier-price (tier (string-ascii 10)))
  (map-get? tier-prices { tier: tier }))