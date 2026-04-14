;; access-control.clar
;; ProofLedger Role-Based Access Control
;; Assign and check roles for protocol participants

(define-constant ROLE_ADMIN u1)
(define-constant ROLE_ISSUER u2)
(define-constant ROLE_VERIFIER u3)
(define-constant ROLE_MODERATOR u4)

(define-map roles
  { address: principal, role: uint }
  { granted-at: uint, granted-by: principal })

(define-data-var contract-owner principal tx-sender)

;; grant-role: owner grants a role to an address
;; Errors: u403 = not owner, u1 = already has role
(define-public (grant-role (address principal) (role uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (is-none (map-get? roles { address: address, role: role })) (err u1))
    (map-set roles { address: address, role: role }
      { granted-at: stacks-block-height, granted-by: tx-sender })
    (ok true)))

;; revoke-role: owner removes a role from an address
;; Errors: u403 = not owner
(define-public (revoke-role (address principal) (role uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (map-delete roles { address: address, role: role })
    (ok true)))

(define-read-only (has-role (address principal) (role uint))
  (is-some (map-get? roles { address: address, role: role })))

(define-read-only (is-admin (address principal))
  (has-role address ROLE_ADMIN))

(define-read-only (is-issuer (address principal))
  (has-role address ROLE_ISSUER))