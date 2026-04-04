;; ProofLedger Verifier Contract
;; verify-proof charges 0.001 STX (1000 micro-STX) to treasury
;; This creates real on-chain transactions for every verification

(define-constant CONTRACT-OWNER tx-sender)
(define-constant VERIFY-FEE u1000) ;; 0.001 STX in micro-STX
(define-constant ERR-ALREADY-VERIFIED (err u101))
(define-constant ERR-PROOF-NOT-FOUND (err u102))
(define-constant ERR-PAYMENT-FAILED (err u103))
(define-constant ERR-INVALID-HASH (err u104))

;; Verification log: hash -> {verifier, block-height, timestamp}
(define-map verification-log
  { proof-hash: (buff 32) }
  {
    verifier: principal,
    block-height: uint,
    verification-count: uint
  }
)

;; Total verifications counter
(define-data-var total-verifications uint u0)
(define-data-var total-fees-collected uint u0)

;; PUBLIC: Verify a proof — charges 0.001 STX
;; Anyone can verify any hash; fee goes to CONTRACT-OWNER
(define-public (verify-proof (proof-hash (buff 32)))
  (let (
    (caller tx-sender)
    (existing (map-get? verification-log { proof-hash: proof-hash }))
  )
    ;; 1. Charge the gas fee first
    (try! (stx-transfer? VERIFY-FEE caller CONTRACT-OWNER))

    ;; 2. Update or insert verification log
    (match existing
      prev-entry
        ;; Already verified — increment count, update verifier
        (begin
          (map-set verification-log
            { proof-hash: proof-hash }
            {
              verifier: caller,
              block-height: block-height,
              verification-count: (+ (get verification-count prev-entry) u1)
            }
          )
        )
      ;; First time verification
      (map-set verification-log
        { proof-hash: proof-hash }
        {
          verifier: caller,
          block-height: block-height,
          verification-count: u1
        }
      )
    )

    ;; 3. Update global counters
    (var-set total-verifications (+ (var-get total-verifications) u1))
    (var-set total-fees-collected (+ (var-get total-fees-collected) VERIFY-FEE))

    ;; 4. Emit event for indexers
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

;; READ: Get verification info for a hash
(define-read-only (get-verification (proof-hash (buff 32)))
  (map-get? verification-log { proof-hash: proof-hash })
)

;; READ: Total verifications ever
(define-read-only (get-total-verifications)
  (ok (var-get total-verifications))
)

;; READ: Total STX fees collected
(define-read-only (get-total-fees)
  (ok (var-get total-fees-collected))
)

;; READ: Current verify fee in micro-STX
(define-read-only (get-verify-fee)
  (ok VERIFY-FEE)
)
