;; subscriptions.clar
;; ProofLedger Wallet Subscriptions
;; Follow other wallets to track their proof activity

(define-map subscriptions
  { subscriber: principal, publisher: principal }
  { subscribed-at: uint, active: bool })

(define-map subscriber-count
  { publisher: principal }
  { count: uint })

;; subscribe: follow a publisher wallet
;; Errors: u1 = cannot subscribe to self, u2 = already subscribed
(define-public (subscribe (publisher principal))
  (let ((count (default-to u0 (get count (map-get? subscriber-count { publisher: publisher })))))
    (asserts! (not (is-eq tx-sender publisher)) (err u1))
    (asserts! (is-none (map-get? subscriptions { subscriber: tx-sender, publisher: publisher })) (err u2))
    (map-set subscriptions { subscriber: tx-sender, publisher: publisher }
      { subscribed-at: stacks-block-height, active: true })
    (map-set subscriber-count { publisher: publisher } { count: (+ count u1) })
    (ok true)))

;; unsubscribe: stop following a wallet
(define-public (unsubscribe (publisher principal))
  (let ((existing (unwrap! (map-get? subscriptions { subscriber: tx-sender, publisher: publisher }) (err u3))))
    (map-set subscriptions { subscriber: tx-sender, publisher: publisher }
      (merge existing { active: false }))
    (ok true)))

(define-read-only (is-subscribed (subscriber principal) (publisher principal))
  (default-to false (get active (map-get? subscriptions { subscriber: subscriber, publisher: publisher }))))

(define-read-only (get-subscriber-count (publisher principal))
  (default-to u0 (get count (map-get? subscriber-count { publisher: publisher }))))