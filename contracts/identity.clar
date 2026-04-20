;; identity.clar
;; ProofLedger Self-Sovereign Identity
;; Link a wallet to a verifiable identity with supporting proofs

(define-map identities
  { principal: principal }
  { display-name: (string-ascii 50), bio: (string-ascii 200),
    identity-hash: (buff 32), created-at: uint,
    last-updated: uint, verified: bool })

(define-map identity-claims
  { principal: principal, claim-type: (string-ascii 50) }
  { proof-hash: (buff 32), claimed-at: uint, attested: bool })

(define-data-var total-identities uint u0)

;; register-identity: wallet creates on-chain identity
;; Errors: u1 = already registered
(define-public (register-identity (display-name (string-ascii 50))
                                    (bio (string-ascii 200))
                                    (identity-hash (buff 32)))
  (begin
    (asserts! (is-none (map-get? identities { principal: tx-sender })) (err u1))
    (map-set identities { principal: tx-sender }
      { display-name: display-name, bio: bio,
        identity-hash: identity-hash,
        created-at: stacks-block-height, last-updated: stacks-block-height,
        verified: false })
    (var-set total-identities (+ (var-get total-identities) u1))
    (ok true)))

;; add-claim: attach a supporting credential to identity
(define-public (add-claim (claim-type (string-ascii 50)) (proof-hash (buff 32)))
  (begin
    (asserts! (is-some (map-get? identities { principal: tx-sender })) (err u2))
    (map-set identity-claims { principal: tx-sender, claim-type: claim-type }
      { proof-hash: proof-hash, claimed-at: stacks-block-height, attested: false })
    (ok true)))

;; update-bio: update display name and bio
(define-public (update-bio (display-name (string-ascii 50)) (bio (string-ascii 200)))
  (let ((id (unwrap! (map-get? identities { principal: tx-sender }) (err u2))))
    (map-set identities { principal: tx-sender }
      (merge id { display-name: display-name, bio: bio,
                  last-updated: stacks-block-height }))
    (ok true)))

(define-read-only (get-identity (user principal))
  (map-get? identities { user: user }))

(define-read-only (get-claim (user principal) (claim-type (string-ascii 50)))
  (map-get? identity-claims { principal: user, claim-type: claim-type }))

(define-read-only (has-identity (user principal))
  (is-some (map-get? identities { principal: user })))