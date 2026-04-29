;; dispute.clar
;; ProofLedger Dispute Resolution
;; Allow principals to raise disputes against anchored hashes for review

(define-map disputes
  { dispute-id: uint }
  { hash:         (buff 32),
    plaintiff:    principal,
    reason:       (string-ascii 200),
    raised-at:    uint,
    resolved:     bool,
    resolution:   (string-ascii 200),
    upheld:       bool })

(define-data-var dispute-admin  principal tx-sender)
(define-data-var dispute-count  uint u0)
(define-data-var open-disputes  uint u0)

;; raise: any principal raises a dispute against a document hash
(define-public (raise (hash   (buff 32))
                       (reason (string-ascii 200)))
  (let ((id (+ (var-get dispute-count) u1)))
    (map-set disputes { dispute-id: id }
      { hash:       hash,
        plaintiff:  tx-sender,
        reason:     reason,
        raised-at:  stacks-block-height,
        resolved:   false,
        resolution: "",
        upheld:     false })
    (var-set dispute-count id)
    (var-set open-disputes (+ (var-get open-disputes) u1))
    (ok id)))

;; resolve: admin closes a dispute with a resolution and verdict
;; Errors: u401 = not admin, u1 = not found, u2 = already resolved
(define-public (resolve (dispute-id uint)
                          (resolution (string-ascii 200))
                          (upheld     bool))
  (begin
    (asserts! (is-eq tx-sender (var-get dispute-admin)) (err u401))
    (let ((d (unwrap! (map-get? disputes { dispute-id: dispute-id }) (err u1))))
      (asserts! (not (get resolved d)) (err u2))
      (map-set disputes { dispute-id: dispute-id }
        (merge d { resolved: true, resolution: resolution, upheld: upheld }))
      (var-set open-disputes
        (if (> (var-get open-disputes) u0)
          (- (var-get open-disputes) u1) u0))
      (ok upheld))))

(define-read-only (get-dispute (dispute-id uint))
  (map-get? disputes { dispute-id: dispute-id }))

(define-read-only (get-dispute-count) (var-get dispute-count))
(define-read-only (get-open-disputes) (var-get open-disputes))