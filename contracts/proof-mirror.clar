;; proof-mirror.clar
;; ProofLedger Cross-Chain Proof Mirror
;; Record that a Stacks proof has been mirrored to Celo (or vice versa)

(define-map mirrors
  { stacks-hash: (buff 32) }
  { celo-tx:     (string-ascii 70),
    celo-block:  uint,
    mirrored-at: uint,
    mirror-agent: principal,
    confirmed:   bool })

(define-map mirror-counts
  { agent: principal }
  { count: uint })

(define-data-var mirror-admin  principal tx-sender)
(define-data-var total-mirrors uint u0)

;; record-mirror: agent attests that a Stacks hash exists on Celo
;; Errors: u1 = already mirrored
(define-public (record-mirror (stacks-hash (buff 32))
                               (celo-tx     (string-ascii 70))
                               (celo-block  uint))
  (begin
    (asserts! (is-none (map-get? mirrors { stacks-hash: stacks-hash })) (err u1))
    (map-set mirrors { stacks-hash: stacks-hash }
      { celo-tx:      celo-tx,
        celo-block:   celo-block,
        mirrored-at:  stacks-block-height,
        mirror-agent: tx-sender,
        confirmed:    false })
    (let ((cur (default-to u0 (get count (map-get? mirror-counts { agent: tx-sender })))))
      (map-set mirror-counts { agent: tx-sender } { count: (+ cur u1) }))
    (var-set total-mirrors (+ (var-get total-mirrors) u1))
    (ok true)))

;; confirm-mirror: admin marks a mirror as verified
;; Errors: u2 = not admin, u3 = not found
(define-public (confirm-mirror (stacks-hash (buff 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get mirror-admin)) (err u2))
    (let ((m (unwrap! (map-get? mirrors { stacks-hash: stacks-hash }) (err u3))))
      (map-set mirrors { stacks-hash: stacks-hash }
        (merge m { confirmed: true }))
      (ok true))))

(define-read-only (get-mirror (stacks-hash (buff 32)))
  (map-get? mirrors { stacks-hash: stacks-hash }))

(define-read-only (is-mirrored (stacks-hash (buff 32)))
  (is-some (map-get? mirrors { stacks-hash: stacks-hash })))

(define-read-only (get-agent-count (agent principal))
  (default-to u0 (get count (map-get? mirror-counts { agent: agent }))))

(define-read-only (get-total-mirrors) (var-get total-mirrors))