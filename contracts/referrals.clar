;; referrals.clar
;; ProofLedger Referral System
;; Track who referred whom to the ProofLedger ecosystem

(define-map referrals
  { referred: principal }
  { referrer: principal, referred-at: uint })

(define-map referral-count
  { referrer: principal }
  { count: uint })

(define-data-var total-referrals uint u0)

;; register-referral: record that a referrer brought in a new user
;; Errors: u1 = already referred, u2 = cannot refer yourself
(define-public (register-referral (referrer principal))
  (let ((count (default-to u0 (get count (map-get? referral-count { referrer: referrer })))))
    (asserts! (is-none (map-get? referrals { referred: tx-sender })) (err u1))
    (asserts! (not (is-eq tx-sender referrer)) (err u2))
    (map-set referrals { referred: tx-sender }
      { referrer: referrer, referred-at: stacks-block-height })
    (map-set referral-count { referrer: referrer } { count: (+ count u1) })
    (var-set total-referrals (+ (var-get total-referrals) u1))
    (ok true)))

(define-read-only (get-referral (referred principal))
  (map-get? referrals { referred: referred }))

(define-read-only (get-referral-count (referrer principal))
  (default-to u0 (get count (map-get? referral-count { referrer: referrer }))))

(define-read-only (get-total-referrals)
  (var-get total-referrals))