;; oracle.clar
;; ProofLedger Oracle Contract
;; Anchor off-chain data feeds on-chain with trusted oracle addresses

(define-map oracles
  { address: principal }
  { name: (string-ascii 100), active: bool, registered-at: uint })

(define-map data-feeds
  { feed-id: (string-ascii 100), oracle: principal }
  { value: (string-ascii 500), updated-at: uint, round: uint })

(define-data-var contract-owner principal tx-sender)

;; register-oracle: owner adds a trusted oracle address
(define-public (register-oracle (oracle principal) (name (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (map-set oracles { address: oracle }
      { name: name, active: true, registered-at: stacks-block-height })
    (ok true)))

;; update-feed: oracle pushes new data
;; Errors: u1 = not an oracle, u2 = oracle inactive
(define-public (update-feed (feed-id (string-ascii 100)) (value (string-ascii 500)))
  (let ((oracle (unwrap! (map-get? oracles { address: tx-sender }) (err u1)))
        (existing (map-get? data-feeds { feed-id: feed-id, oracle: tx-sender }))
        (round (default-to u0 (get round existing))))
    (asserts! (get active oracle) (err u2))
    (map-set data-feeds { feed-id: feed-id, oracle: tx-sender }
      { value: value, updated-at: stacks-block-height, round: (+ round u1) })
    (ok true)))

(define-read-only (get-feed (feed-id (string-ascii 100)) (oracle principal))
  (map-get? data-feeds { feed-id: feed-id, oracle: oracle }))