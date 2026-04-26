;; whitelist.clar
;; ProofLedger Whitelist
;; Optional gating layer — admin controls who may submit anchors

(define-map whitelist
  { address: principal }
  { added-at: uint, active: bool, label: (string-ascii 60) })

(define-data-var whitelist-admin  principal tx-sender)
(define-data-var whitelist-enabled bool false)
(define-data-var total-whitelisted uint u0)

;; add: admin adds a principal to the whitelist
;; Errors: u401 = not admin, u1 = already listed
(define-public (add (address principal) (label (string-ascii 60)))
  (begin
    (asserts! (is-eq tx-sender (var-get whitelist-admin)) (err u401))
    (asserts! (is-none (map-get? whitelist { address: address })) (err u1))
    (map-set whitelist { address: address }
      { added-at: stacks-block-height, active: true, label: label })
    (var-set total-whitelisted (+ (var-get total-whitelisted) u1))
    (ok true)))

;; remove: admin removes a principal
;; Errors: u401 = not admin, u2 = not found
(define-public (remove (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get whitelist-admin)) (err u401))
    (let ((entry (unwrap! (map-get? whitelist { address: address }) (err u2))))
      (map-set whitelist { address: address } (merge entry { active: false }))
      (ok true))))

;; set-enabled: admin toggles whether whitelist is enforced
(define-public (set-enabled (enabled bool))
  (begin
    (asserts! (is-eq tx-sender (var-get whitelist-admin)) (err u401))
    (var-set whitelist-enabled enabled)
    (ok true)))

;; is-allowed: returns true if whitelist is off, or address is active
(define-read-only (is-allowed (address principal))
  (if (not (var-get whitelist-enabled))
    true
    (match (map-get? whitelist { address: address })
      e (get active e)
      false)))

(define-read-only (get-entry (address principal))
  (map-get? whitelist { address: address }))

(define-read-only (is-enabled)    (var-get whitelist-enabled))
(define-read-only (get-total)     (var-get total-whitelisted))