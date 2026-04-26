;; genesis.clar
;; ProofLedger Genesis
;; Bootstrap the protocol initial state — record the founding anchor

(define-map genesis-records
  { genesis-id: uint }
  { creator:      principal,
    hash:         (buff 32),
    message:      (string-ascii 200),
    recorded-at:  uint,
    finalized:    bool })

(define-data-var genesis-admin  principal tx-sender)
(define-data-var genesis-count  uint u0)
(define-data-var protocol-live  bool false)

;; record-genesis: admin records a founding anchor
;; Errors: u401 = not admin, u1 = already finalized
(define-public (record-genesis (hash (buff 32)) (message (string-ascii 200)))
  (begin
    (asserts! (is-eq tx-sender (var-get genesis-admin)) (err u401))
    (asserts! (not (var-get protocol-live)) (err u1))
    (let ((id (+ (var-get genesis-count) u1)))
      (map-set genesis-records { genesis-id: id }
        { creator:     tx-sender,
          hash:        hash,
          message:     message,
          recorded-at: stacks-block-height,
          finalized:   false })
      (var-set genesis-count id)
      (ok id))))

;; finalize: lock genesis and mark protocol as live
;; Errors: u401 = not admin, u2 = nothing recorded yet
(define-public (finalize)
  (begin
    (asserts! (is-eq tx-sender (var-get genesis-admin)) (err u401))
    (asserts! (> (var-get genesis-count) u0) (err u2))
    (var-set protocol-live true)
    (let ((latest (var-get genesis-count)))
      (match (map-get? genesis-records { genesis-id: latest })
        r (map-set genesis-records { genesis-id: latest }
            (merge r { finalized: true }))
        false))
    (ok true)))

(define-read-only (get-genesis (genesis-id uint))
  (map-get? genesis-records { genesis-id: genesis-id }))

(define-read-only (is-live)          (var-get protocol-live))
(define-read-only (get-genesis-count) (var-get genesis-count))