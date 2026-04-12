;; vouchers.clar
;; ProofLedger Voucher System
;; Issue and redeem one-time use vouchers linked to document hashes

(define-map vouchers
  { code: (string-ascii 32) }
  { issuer: principal, recipient: (optional principal), hash: (buff 32),
    value: uint, redeemed: bool, created-at: uint, expires-at: uint })

(define-data-var total-vouchers uint u0)

;; issue-voucher: create a one-time voucher linked to a document hash
;; Errors: u1 = code already exists, u2 = invalid expiry
(define-public (issue-voucher (code (string-ascii 32)) (hash (buff 32)) (value uint) (expires-in uint))
  (begin
    (asserts! (is-none (map-get? vouchers { code: code })) (err u1))
    (asserts! (> expires-in u0) (err u2))
    (map-set vouchers { code: code }
      { issuer: tx-sender, recipient: none, hash: hash, value: value,
        redeemed: false, created-at: stacks-block-height,
        expires-at: (+ stacks-block-height expires-in) })
    (var-set total-vouchers (+ (var-get total-vouchers) u1))
    (ok true)))

;; redeem-voucher: claim a voucher
;; Errors: u3 = not found, u4 = already redeemed, u5 = expired
(define-public (redeem-voucher (code (string-ascii 32)))
  (let ((v (unwrap! (map-get? vouchers { code: code }) (err u3))))
    (asserts! (not (get redeemed v)) (err u4))
    (asserts! (<= stacks-block-height (get expires-at v)) (err u5))
    (map-set vouchers { code: code }
      (merge v { redeemed: true, recipient: (some tx-sender) }))
    (ok (get hash v))))

(define-read-only (get-voucher (code (string-ascii 32)))
  (map-get? vouchers { code: code }))

(define-read-only (is-valid-voucher (code (string-ascii 32)))
  (match (map-get? vouchers { code: code })
    v (and (not (get redeemed v)) (<= stacks-block-height (get expires-at v)))
    false))