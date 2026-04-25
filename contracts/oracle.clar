;; oracle.clar
;; ProofLedger On-Chain Oracle
;; Store and retrieve verified data feeds (e.g. per-type fees, block timestamps)

(define-map feeds
  { feed-key: (string-ascii 50) }
  { value: uint,
    reporter: principal,
    updated-at: uint,
    round: uint,
    description: (string-ascii 100) })

(define-map authorized-reporters
  { reporter: principal }
  { authorized-at: uint, active: bool })

(define-data-var oracle-admin principal tx-sender)
(define-data-var stale-threshold uint u144) ;; blocks before a feed is considered stale

;; Seed default feeds
(map-set feeds { feed-key: "anchor-fee-diploma"       } { value: u1000, reporter: tx-sender, updated-at: u0, round: u1, description: "Diploma anchor fee in uSTX" })
(map-set feeds { feed-key: "anchor-fee-certificate"   } { value: u800,  reporter: tx-sender, updated-at: u0, round: u1, description: "Certificate anchor fee in uSTX" })
(map-set feeds { feed-key: "anchor-fee-research"      } { value: u1200, reporter: tx-sender, updated-at: u0, round: u1, description: "Research anchor fee in uSTX" })

;; authorize-reporter: admin adds a trusted data reporter
(define-public (authorize-reporter (reporter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get oracle-admin)) (err u401))
    (map-set authorized-reporters { reporter: reporter }
      { authorized-at: stacks-block-height, active: true })
    (ok true)))

;; update-feed: authorized reporter submits a new value
;; Errors: u402 = not authorized reporter
(define-public (update-feed (feed-key (string-ascii 50)) (value uint))
  (let ((auth (unwrap! (map-get? authorized-reporters { reporter: tx-sender }) (err u402))))
    (asserts! (get active auth) (err u402))
    (let ((current (default-to
            { value: u0, reporter: tx-sender, updated-at: u0, round: u0, description: "" }
            (map-get? feeds { feed-key: feed-key }))))
      (map-set feeds { feed-key: feed-key }
        { value:       value,
          reporter:    tx-sender,
          updated-at:  stacks-block-height,
          round:       (+ (get round current) u1),
          description: (get description current) })
      (ok value))))

(define-read-only (get-feed (feed-key (string-ascii 50)))
  (map-get? feeds { feed-key: feed-key }))

(define-read-only (get-feed-value (feed-key (string-ascii 50)))
  (match (map-get? feeds { feed-key: feed-key })
    f (some (get value f))
    none))

(define-read-only (is-feed-fresh (feed-key (string-ascii 50)))
  (match (map-get? feeds { feed-key: feed-key })
    f (<= (- stacks-block-height (get updated-at f)) (var-get stale-threshold))
    false))