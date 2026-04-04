;; ProofLedger Verifier Contract
(define-constant CONTRACT-OWNER tx-sender)
(define-constant VERIFY-FEE u1000)
(define-constant ERR-PAYMENT-FAILED (err u103))

(define-map verification-log
  { proof-hash: (buff 32) }
  { verifier: principal, block-height: uint, verification-count: uint }
)

(define-data-var total-verifications uint u0)
(define-data-var total-fees-collected uint u0)

(define-public (verify-proof (proof-hash (buff 32)))
  (let (
    (caller tx-sender)
    (existing (map-get? verification-log { proof-hash: proof-hash }))
  )
    (try! (stx-transfer? VERIFY-FEE caller CONTRACT-OWNER))
    (match existing
      prev-entry
        (map-set verification-log
          { proof-hash: proof-hash }
          { verifier: caller, block-height: block-height,
            verification-count: (+ (get verification-count prev-entry) u1) }
        )
      (map-set verification-log
        { proof-hash: proof-hash }
        { verifier: caller, block-height: block-height, verification-count: u1 }
      )
    )
    (var-set total-verifications (+ (var-get total-verifications) u1))
    (var-set total-fees-collected (+ (var-get total-fees-collected) VERIFY-FEE))
    (print {
      event: "proof-verified",
      proof-hash: proof-hash,
      verifier: caller,
      block: block-height,
      fee-paid: VERIFY-FEE
    })
    (ok true)
  )
)

(define-read-only (get-verification (proof-hash (buff 32)))
  (map-get? verification-log { proof-hash: proof-hash })
)
(define-read-only (get-total-verifications) (ok (var-get total-verifications)))
(define-read-only (get-total-fees) (ok (var-get total-fees-collected)))
(define-read-only (get-verify-fee) (ok VERIFY-FEE))
