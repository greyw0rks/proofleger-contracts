;; vote-delegation.clar
;; Delegate voting power to another address with optional scope limits
;; Errors:
;;   u100 - already delegated
;;   u101 - no delegation found
;;   u102 - self-delegation
;;   u103 - delegation expired

(define-constant CONTRACT-OWNER tx-sender)

(define-map delegations principal
  { delegate: principal, power: uint, expires-at: uint, scope: (string-ascii 20) })

(define-map delegated-power principal uint)

(define-public (delegate-vote
  (delegate principal)
  (power uint)
  (duration uint)
  (scope (string-ascii 20)))
  (begin
    (asserts! (not (is-eq tx-sender delegate)) (err u102))
    (asserts! (is-none (map-get? delegations tx-sender)) (err u100))
    (map-set delegations tx-sender
      { delegate: delegate, power: power,
        expires-at: (+ block-height duration), scope: scope })
    (map-set delegated-power delegate
      (+ (default-to u0 (map-get? delegated-power delegate)) power))
    (ok delegate)))

(define-public (revoke-delegation)
  (let ((d (unwrap! (map-get? delegations tx-sender) (err u101))))
    (map-set delegated-power (get delegate d)
      (- (default-to u0 (map-get? delegated-power (get delegate d))) (get power d)))
    (map-delete delegations tx-sender)
    (ok true)))

(define-read-only (get-delegation (address principal))
  (map-get? delegations address))

(define-read-only (get-effective-power (address principal))
  (default-to u0 (map-get? delegated-power address)))

(define-read-only (is-delegation-valid? (address principal))
  (match (map-get? delegations address)
    d (<= block-height (get expires-at d))
    false))
