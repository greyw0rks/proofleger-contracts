;; fee-collector.clar
;; ProofLedger Protocol Fee Collector
;; Collect and distribute protocol fees to stakeholders

(define-data-var contract-owner principal tx-sender)
(define-data-var total-collected uint u0)
(define-data-var fee-per-anchor uint u1000) ;; 0.001 STX default

(define-map balances
  { recipient: principal }
  { amount: uint })

(define-map fee-recipients
  { index: uint }
  { address: principal, share: uint }) ;; share out of 100

(define-data-var recipient-count uint u0)

;; collect-fee: accept a fee payment from a protocol user
(define-public (collect-fee (payer principal))
  (let ((fee (var-get fee-per-anchor)))
    (try! (stx-transfer? fee payer (as-contract tx-sender)))
    (var-set total-collected (+ (var-get total-collected) fee))
    (ok fee)))

;; add-recipient: owner registers a fee recipient with a share
;; Errors: u403 = not owner, u1 = shares would exceed 100
(define-public (add-recipient (address principal) (share uint))
  (let ((count (var-get recipient-count)))
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (<= share u100) (err u1))
    (map-set fee-recipients { index: count } { address: address, share: share })
    (var-set recipient-count (+ count u1))
    (ok true)))

;; set-fee: owner updates the fee amount
(define-public (set-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (var-set fee-per-anchor new-fee)
    (ok true)))

(define-read-only (get-fee) (var-get fee-per-anchor))
(define-read-only (get-total-collected) (var-get total-collected))