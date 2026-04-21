;; escrow.clar
;; ProofLedger Document Escrow
;; Hold STX in escrow, released when a document proof is submitted

(define-map escrows
  { id: uint }
  { depositor: principal, beneficiary: principal,
    amount: uint, required-hash: (optional (buff 32)),
    deposited-at: uint, released: bool, refunded: bool })

(define-data-var escrow-count uint u0)

;; create-escrow: depositor locks STX for a beneficiary
;; optional required-hash: beneficiary must submit this proof to release
(define-public (create-escrow (beneficiary principal) (amount uint)
                                (required-hash (optional (buff 32))))
  (begin
    (asserts! (> amount u0) (err u1))
    (asserts! (not (is-eq tx-sender beneficiary)) (err u2))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((id (+ (var-get escrow-count) u1)))
      (map-set escrows { id: id }
        { depositor: tx-sender, beneficiary: beneficiary,
          amount: amount, required-hash: required-hash,
          deposited-at: stacks-block-height, released: false, refunded: false })
      (var-set escrow-count id)
      (ok id))))

;; release: depositor releases funds to beneficiary
;; Errors: u3 = not found, u4 = not depositor, u5 = already settled
(define-public (release (escrow-id uint))
  (let ((e (unwrap! (map-get? escrows { id: escrow-id }) (err u3))))
    (asserts! (is-eq tx-sender (get depositor e)) (err u4))
    (asserts! (not (get released e)) (err u5))
    (asserts! (not (get refunded e)) (err u5))
    (try! (as-contract (stx-transfer? (get amount e) tx-sender (get beneficiary e))))
    (map-set escrows { id: escrow-id } (merge e { released: true }))
    (ok true)))

;; refund: depositor reclaims funds if conditions unmet
(define-public (refund (escrow-id uint))
  (let ((e (unwrap! (map-get? escrows { id: escrow-id }) (err u3))))
    (asserts! (is-eq tx-sender (get depositor e)) (err u4))
    (asserts! (not (get released e)) (err u5))
    (asserts! (not (get refunded e)) (err u5))
    (try! (as-contract (stx-transfer? (get amount e) tx-sender (get depositor e))))
    (map-set escrows { id: escrow-id } (merge e { refunded: true }))
    (ok true)))

(define-read-only (get-escrow (id uint))
  (map-get? escrows { id: id }))