;; access-control.clar
;; ProofLedger Role-Based Access Control
;; Assign and check roles for contract permission management

(define-map roles
  { account: principal, role: (string-ascii 50) }
  { granted-at: uint, granted-by: principal })

(define-map role-admins
  { role: (string-ascii 50) }
  { admin-role: (string-ascii 50) })

(define-data-var super-admin principal tx-sender)

;; Built-in roles
(define-constant ADMIN-ROLE "admin")
(define-constant ISSUER-ROLE "issuer")
(define-constant VERIFIER-ROLE "verifier")
(define-constant OPERATOR-ROLE "operator")

;; Grant initial admin role to deployer
(map-set roles { account: tx-sender, role: ADMIN-ROLE }
  { granted-at: u0, granted-by: tx-sender })

;; grant-role: admin grants a role to an account
;; Errors: u403 = not admin
(define-public (grant-role (account principal) (role (string-ascii 50)))
  (begin
    (asserts! (has-role tx-sender ADMIN-ROLE) (err u403))
    (map-set roles { account: account, role: role }
      { granted-at: stacks-block-height, granted-by: tx-sender })
    (ok true)))

;; revoke-role: admin revokes a role from an account
(define-public (revoke-role (account principal) (role (string-ascii 50)))
  (begin
    (asserts! (has-role tx-sender ADMIN-ROLE) (err u403))
    (map-delete roles { account: account, role: role })
    (ok true)))

(define-read-only (has-role (account principal) (role (string-ascii 50)))
  (is-some (map-get? roles { account: account, role: role })))

(define-read-only (get-role-info (account principal) (role (string-ascii 50)))
  (map-get? roles { account: account, role: role }))