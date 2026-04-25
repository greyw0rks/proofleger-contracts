;; fee-registry.clar
;; ProofLedger Fee Registry
;; Manage and collect per-action protocol fees

(define-map fees
  { action: (string-ascii 50) }
  { amount-ustx: uint, enabled: bool, collected: uint })

(define-data-var fee-admin   principal tx-sender)
(define-data-var fee-treasury principal tx-sender)
(define-data-var total-collected uint u0)

;; Seed default fees
(map-set fees { action: "anchor" }      { amount-ustx: u1000, enabled: false, collected: u0 })
(map-set fees { action: "attest" }      { amount-ustx: u500,  enabled: false, collected: u0 })
(map-set fees { action: "mint-badge" }  { amount-ustx: u2000, enabled: false, collected: u0 })

;; set-fee: admin configures the fee for an action
;; Errors: u401 = not admin
(define-public (set-fee (action (string-ascii 50)) (amount-ustx uint) (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-admin)) (err u401))
    (let ((existing (default-to { amount-ustx: u0, enabled: false, collected: u0 }
            (map-get? fees { action: action }))))
      (map-set fees { action: action }
        (merge existing { amount-ustx: amount-ustx, enabled: enabled })))
    (ok true)))

;; collect-fee: called by other contracts to collect the fee for an action
;; Errors: u402 = fee not found, u403 = fee disabled, u404 = insufficient payment
(define-public (collect-fee (action (string-ascii 50)) (payer principal))
  (let ((fee (unwrap! (map-get? fees { action: action }) (err u402))))
    (asserts! (get enabled fee) (err u403))
    (let ((amount (get amount-ustx fee)))
      (if (> amount u0)
        (begin
          (try! (stx-transfer? amount payer (var-get fee-treasury)))
          (map-set fees { action: action }
            (merge fee { collected: (+ (get collected fee) amount) }))
          (var-set total-collected (+ (var-get total-collected) amount))
          (ok amount))
        (ok u0)))))

(define-public (set-treasury (new-treasury principal))
  (begin
    (asserts! (is-eq tx-sender (var-get fee-admin)) (err u401))
    (var-set fee-treasury new-treasury)
    (ok true)))

(define-read-only (get-fee (action (string-ascii 50)))
  (map-get? fees { action: action }))

(define-read-only (get-fee-amount (action (string-ascii 50)))
  (match (map-get? fees { action: action })
    f (if (get enabled f) (some (get amount-ustx f)) none)
    none))

(define-read-only (get-total-collected) (var-get total-collected))