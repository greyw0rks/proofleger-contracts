;; whitelist.clar
;; ProofLedger Access Whitelist
;; Manage access to gated ProofLedger features

(define-map whitelist
  { address: principal }
  { added-at: uint, added-by: principal, tier: (string-ascii 20) })

(define-data-var contract-owner principal tx-sender)
(define-data-var whitelist-count uint u0)

;; add-to-whitelist: owner adds an address with a tier
;; Errors: u403 = not owner, u1 = already whitelisted
(define-public (add-to-whitelist (address principal) (tier (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (is-none (map-get? whitelist { address: address })) (err u1))
    (map-set whitelist { address: address }
      { added-at: stacks-block-height, added-by: tx-sender, tier: tier })
    (var-set whitelist-count (+ (var-get whitelist-count) u1))
    (ok true)))

;; remove-from-whitelist: owner removes an address
(define-public (remove-from-whitelist (address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (map-delete whitelist { address: address })
    (ok true)))

(define-read-only (is-whitelisted (address principal))
  (is-some (map-get? whitelist { address: address })))

(define-read-only (get-whitelist-entry (address principal))
  (map-get? whitelist { address: address }))