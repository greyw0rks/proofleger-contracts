;; oracle.clar
;; ProofLedger On-Chain Oracle
;; Authorized oracle feeds for contract data dependencies

(define-map oracle-data
  { feed: (string-ascii 50) }
  { value: uint, updated-at: uint, updater: principal,
    description: (string-ascii 100) })

(define-map authorized-updaters
  { updater: principal }
  { active: bool, added-at: uint })

(define-data-var oracle-owner principal tx-sender)

;; authorize-updater: owner grants oracle update rights
(define-public (authorize-updater (updater principal))
  (begin
    (asserts! (is-eq tx-sender (var-get oracle-owner)) (err u401))
    (map-set authorized-updaters { updater: updater } { active: true, added-at: stacks-block-height })
    (ok true)))

;; update-feed: authorized updater pushes a new value
;; Errors: u403 = not authorized, u1 = invalid value
(define-public (update-feed (feed (string-ascii 50)) (value uint) (description (string-ascii 100)))
  (begin
    (asserts!
      (or (is-eq tx-sender (var-get oracle-owner))
          (default-to false (get active (map-get? authorized-updaters { updater: tx-sender }))))
      (err u403))
    (map-set oracle-data { feed: feed }
      { value: value, updated-at: stacks-block-height,
        updater: tx-sender, description: description })
    (ok true)))

(define-read-only (get-feed (feed (string-ascii 50)))
  (map-get? oracle-data { feed: feed }))

(define-read-only (get-feed-value (feed (string-ascii 50)))
  (get value (map-get? oracle-data { feed: feed })))

(define-read-only (is-authorized (updater principal))
  (default-to false (get active (map-get? authorized-updaters { updater: updater }))))