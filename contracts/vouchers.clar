;; vouchers.clar
;; ProofLedger Single-Use Credential Vouchers
;; Issue redeemable vouchers tied to document proof hashes

(define-map vouchers
  { code: (buff 32) }
  { issuer: principal, proof-hash: (buff 32),
    voucher-type: (string-ascii 50),
    redeemed: bool, redeemed-by: (optional principal),
    redeemed-at: (optional uint), created-at: uint, active: bool })

(define-data-var total-vouchers uint u0)

;; issue-voucher: issuer creates a voucher backed by a document proof
;; Errors: u1 = code already exists
(define-public (issue-voucher (code (buff 32)) (proof-hash (buff 32))
                                (voucher-type (string-ascii 50)))
  (begin
    (asserts! (is-none (map-get? vouchers { code: code })) (err u1))
    (map-set vouchers { code: code }
      { issuer: tx-sender, proof-hash: proof-hash,
        voucher-type: voucher-type, redeemed: false,
        redeemed-by: none, redeemed-at: none,
        created-at: stacks-block-height, active: true })
    (var-set total-vouchers (+ (var-get total-vouchers) u1))
    (ok true)))

;; redeem-voucher: holder redeems a voucher (single use)
;; Errors: u2 = not found, u3 = already redeemed, u4 = not active
(define-public (redeem-voucher (code (buff 32)))
  (let ((voucher (unwrap! (map-get? vouchers { code: code }) (err u2))))
    (asserts! (not (get redeemed voucher)) (err u3))
    (asserts! (get active voucher) (err u4))
    (map-set vouchers { code: code }
      (merge voucher { redeemed: true, redeemed-by: (some tx-sender),
                       redeemed-at: (some stacks-block-height) }))
    (ok true)))

(define-read-only (get-voucher (code (buff 32)))
  (map-get? vouchers { code: code }))

(define-read-only (is-redeemed (code (buff 32)))
  (default-to false (get redeemed (map-get? vouchers { code: code }))))