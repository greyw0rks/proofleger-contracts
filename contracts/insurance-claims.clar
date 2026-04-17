;; insurance-claims.clar
;; ProofLedger Insurance Claims
;; Record insurance claims with document proof and adjudicator verification

(define-map claims
  { claim-id: uint }
  { claimant: principal, insurer: principal,
    claim-hash: (buff 32), claim-type: (string-ascii 50),
    filed-at: uint, status: (string-ascii 20),
    adjudicator: (optional principal) })

(define-data-var claim-count uint u0)

;; file-claim: claimant files a new insurance claim
(define-public (file-claim (claim-hash (buff 32)) (insurer principal)
                             (claim-type (string-ascii 50)))
  (let ((id (+ (var-get claim-count) u1)))
    (map-set claims { claim-id: id }
      { claimant: tx-sender, insurer: insurer,
        claim-hash: claim-hash, claim-type: claim-type,
        filed-at: stacks-block-height, status: "pending",
        adjudicator: none })
    (var-set claim-count id)
    (ok id)))

;; adjudicate-claim: insurer updates claim status
;; Errors: u1 = not found, u2 = not insurer
(define-public (adjudicate-claim (claim-id uint) (status (string-ascii 20)))
  (let ((claim (unwrap! (map-get? claims { claim-id: claim-id }) (err u1))))
    (asserts! (is-eq tx-sender (get insurer claim)) (err u2))
    (map-set claims { claim-id: claim-id }
      (merge claim { status: status, adjudicator: (some tx-sender) }))
    (ok true)))

(define-read-only (get-claim (claim-id uint))
  (map-get? claims { claim-id: claim-id }))

(define-read-only (get-claim-count) (var-get claim-count))