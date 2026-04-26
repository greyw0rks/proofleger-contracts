;; delegation.clar
;; ProofLedger Delegation
;; Allow a principal to delegate anchor/attest authority to another wallet

(define-map delegations
  { delegator: principal }
  { delegate:    principal,
    granted-at:  uint,
    expires-at:  uint,    ;; 0 = no expiry
    active:      bool,
    anchor-only: bool })

(define-map delegate-index
  { delegate: principal }
  { delegator: principal })

;; grant: delegator grants rights to a delegate address
;; Errors: u1 = already delegated
(define-public (grant (delegate principal) (expires-at uint) (anchor-only bool))
  (begin
    (asserts! (is-none (map-get? delegations { delegator: tx-sender })) (err u1))
    (map-set delegations { delegator: tx-sender }
      { delegate:    delegate,
        granted-at:  stacks-block-height,
        expires-at:  expires-at,
        active:      true,
        anchor-only: anchor-only })
    (map-set delegate-index { delegate: delegate } { delegator: tx-sender })
    (ok true)))

;; revoke: delegator cancels delegation
;; Errors: u2 = not found
(define-public (revoke)
  (let ((d (unwrap! (map-get? delegations { delegator: tx-sender }) (err u2))))
    (map-delete delegate-index { delegate: (get delegate d) })
    (map-delete delegations    { delegator: tx-sender })
    (ok true)))

;; is-authorized: check if a principal may act on behalf of the delegator
(define-read-only (is-authorized (actor principal) (delegator principal))
  (match (map-get? delegations { delegator: delegator })
    d (and
        (is-eq (get delegate d) actor)
        (get active d)
        (or (is-eq (get expires-at d) u0)
            (< stacks-block-height (get expires-at d))))
    false))

(define-read-only (get-delegation (delegator principal))
  (map-get? delegations { delegator: delegator }))

(define-read-only (get-delegator-for (delegate principal))
  (map-get? delegate-index { delegate: delegate }))