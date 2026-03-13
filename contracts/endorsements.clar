;; endorsements.clar
;; ProofLedger Endorsement Contract
;; Deployed on Stacks Mainnet by SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK
;;
;; Lightweight on-chain endorsements — a +1 social signal for any anchored document.
;; Unlike attestations, endorsements require no credential type.
;; One endorsement per wallet per hash. Cannot endorse your own document.

;; ---------------------------------------------------------------------------
;; DATA MAPS
;; ---------------------------------------------------------------------------

(define-map endorsements
  { hash: (buff 32), endorser: principal }
  { endorsed-at: uint })

(define-map endorsement-count
  { hash: (buff 32) }
  { count: uint })

(define-map endorsement-index
  { hash: (buff 32), index: uint }
  { endorser: principal })

(define-map doc-owners
  { hash: (buff 32) }
  { owner: principal })

;; ---------------------------------------------------------------------------
;; PUBLIC FUNCTIONS
;; ---------------------------------------------------------------------------

;; register-doc-owner
;; Registers the owner of a document hash for self-endorse prevention.
(define-public (register-doc-owner (hash (buff 32)) (owner principal))
  (begin
    (map-set doc-owners { hash: hash } { owner: owner })
    (ok true)))

;; endorse
;; Adds a +1 endorsement to a document hash.
;; Errors:
;;   u1 - already endorsed this hash
;;   u2 - cannot endorse your own document
(define-public (endorse (hash (buff 32)))
  (let (
    (existing (map-get? endorsements { hash: hash, endorser: tx-sender }))
    (count (default-to u0 (get count (map-get? endorsement-count { hash: hash }))))
    (owner-entry (map-get? doc-owners { hash: hash })))
    (asserts! (is-none existing) (err u1))
    (match owner-entry
      entry (asserts! (not (is-eq tx-sender (get owner entry))) (err u2))
      true)
    (map-set endorsements
      { hash: hash, endorser: tx-sender }
      { endorsed-at: stacks-block-height })
    (map-set endorsement-count
      { hash: hash }
      { count: (+ count u1) })
    (map-set endorsement-index
      { hash: hash, index: count }
      { endorser: tx-sender })
    (ok true)))

;; revoke-endorsement
;; Removes the caller's endorsement from a document.
;; Errors:
;;   u3 - no endorsement found to revoke
(define-public (revoke-endorsement (hash (buff 32)))
  (let (
    (existing (map-get? endorsements { hash: hash, endorser: tx-sender })))
    (asserts! (is-some existing) (err u3))
    (map-delete endorsements { hash: hash, endorser: tx-sender })
    (ok true)))

;; ---------------------------------------------------------------------------
;; READ-ONLY FUNCTIONS
;; ---------------------------------------------------------------------------

(define-read-only (get-endorsement-count (hash (buff 32)))
  (default-to u0 (get count (map-get? endorsement-count { hash: hash }))))

(define-read-only (has-endorsed (hash (buff 32)) (endorser principal))
  (is-some (map-get? endorsements { hash: hash, endorser: endorser })))

(define-read-only (get-endorser-at (hash (buff 32)) (index uint))
  (map-get? endorsement-index { hash: hash, index: index }))
