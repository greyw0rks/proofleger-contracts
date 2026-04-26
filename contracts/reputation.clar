;; reputation.clar
;; ProofLedger Reputation System
;; Score issuers and holders based on verified anchors and attestations

(define-map scores
  { principal: principal }
  { anchor-count:  uint,
    attest-count:  uint,
    verify-count:  uint,
    slash-count:   uint,
    score:         uint,
    last-updated:  uint })

(define-data-var score-admin principal tx-sender)

;; Weight constants (points per action)
(define-constant ANCHOR-WEIGHT  u10)
(define-constant ATTEST-WEIGHT  u5)
(define-constant VERIFY-WEIGHT  u2)
(define-constant SLASH-PENALTY  u50)

;; record-anchor: add anchor points for a principal
;; Errors: u401 = not authorized
(define-public (record-anchor (who principal))
  (begin
    (asserts! (is-eq tx-sender (var-get score-admin)) (err u401))
    (let ((s (get-or-init who)))
      (let ((new-anchors (+ (get anchor-count s) u1))
            (new-score   (- (+ (get score s) ANCHOR-WEIGHT)
                            (* (get slash-count s) SLASH-PENALTY))))
        (map-set scores { principal: who }
          (merge s { anchor-count: new-anchors,
                     score:        (if (> new-score u0) new-score u0),
                     last-updated: stacks-block-height }))
        (ok (if (> new-score u0) new-score u0))))))

;; record-attest: add attestation points
(define-public (record-attest (who principal))
  (begin
    (asserts! (is-eq tx-sender (var-get score-admin)) (err u401))
    (let ((s (get-or-init who)))
      (let ((new-score (+ (get score s) ATTEST-WEIGHT)))
        (map-set scores { principal: who }
          (merge s { attest-count: (+ (get attest-count s) u1),
                     score: new-score, last-updated: stacks-block-height }))
        (ok new-score)))))

;; slash: penalize a principal, reducing their score
(define-public (slash (who principal))
  (begin
    (asserts! (is-eq tx-sender (var-get score-admin)) (err u401))
    (let ((s (get-or-init who)))
      (let ((new-slashes (+ (get slash-count s) u1))
            (new-score   (if (> (get score s) SLASH-PENALTY)
                           (- (get score s) SLASH-PENALTY) u0)))
        (map-set scores { principal: who }
          (merge s { slash-count: new-slashes, score: new-score,
                     last-updated: stacks-block-height }))
        (ok new-score)))))

(define-private (get-or-init (who principal))
  (default-to
    { anchor-count: u0, attest-count: u0, verify-count: u0,
      slash-count: u0, score: u0, last-updated: u0 }
    (map-get? scores { principal: who })))

(define-read-only (get-score (who principal))
  (map-get? scores { principal: who }))

(define-read-only (get-score-value (who principal))
  (default-to u0 (get score (map-get? scores { principal: who }))))