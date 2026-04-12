;; identity.clar
;; ProofLedger Self-Sovereign Identity
;; Link DIDs and identity claims to Stacks wallets

(define-map identities
  { owner: principal }
  { did: (string-ascii 256), display-name: (string-ascii 100),
    avatar-hash: (optional (buff 32)), created-at: uint, updated-at: uint })

(define-map identity-claims
  { owner: principal, claim-type: (string-ascii 50) }
  { value: (string-ascii 200), proof-hash: (buff 32), issued-at: uint, issuer: principal })

(define-data-var total-identities uint u0)

;; register-identity: create a DID-linked identity
;; Errors: u1 = already registered
(define-public (register-identity (did (string-ascii 256)) (display-name (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? identities { owner: tx-sender })) (err u1))
    (asserts! (> (len did) u0) (err u2))
    (map-set identities { owner: tx-sender }
      { did: did, display-name: display-name, avatar-hash: none,
        created-at: stacks-block-height, updated-at: stacks-block-height })
    (var-set total-identities (+ (var-get total-identities) u1))
    (ok true)))

;; add-claim: attach a verifiable claim to an identity
(define-public (add-claim (claim-type (string-ascii 50)) (value (string-ascii 200)) (proof-hash (buff 32)))
  (begin
    (asserts! (is-some (map-get? identities { owner: tx-sender })) (err u3))
    (map-set identity-claims { owner: tx-sender, claim-type: claim-type }
      { value: value, proof-hash: proof-hash, issued-at: stacks-block-height, issuer: tx-sender })
    (ok true)))

(define-read-only (get-identity (owner principal))
  (map-get? identities { owner: owner }))

(define-read-only (get-claim (owner principal) (claim-type (string-ascii 50)))
  (map-get? identity-claims { owner: owner, claim-type: claim-type }))