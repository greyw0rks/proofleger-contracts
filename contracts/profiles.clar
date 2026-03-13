;; profiles.clar
;; ProofLedger On-Chain Profile Contract
;; Deployed on Stacks Mainnet by SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK
;;
;; Decentralized profile storage — display name, bio, and category on Bitcoin.
;; One profile per wallet. Update by calling set-profile again.
;; Profiles are publicly readable by anyone.

;; ---------------------------------------------------------------------------
;; DATA MAPS
;; ---------------------------------------------------------------------------

(define-map profiles
  { owner: principal }
  {
    display-name: (string-ascii 50),
    bio: (string-ascii 200),
    category: (string-ascii 50),
    updated-at: uint
  })

(define-data-var total-profiles uint u0)

;; ---------------------------------------------------------------------------
;; PUBLIC FUNCTIONS
;; ---------------------------------------------------------------------------

;; set-profile
;; Creates or updates the caller's on-chain profile.
;; Parameters:
;;   display-name - public display name (max 50 chars, required)
;;   bio          - short bio or description (max 200 chars)
;;   category     - primary document category (max 50 chars)
;; Errors:
;;   u1 - display-name is empty
(define-public (set-profile
  (display-name (string-ascii 50))
  (bio (string-ascii 200))
  (category (string-ascii 50)))
  (let (
    (is-new (is-none (map-get? profiles { owner: tx-sender }))))
    (asserts! (> (len display-name) u0) (err u1))
    (map-set profiles
      { owner: tx-sender }
      {
        display-name: display-name,
        bio: bio,
        category: category,
        updated-at: stacks-block-height
      })
    (if is-new
      (var-set total-profiles (+ (var-get total-profiles) u1))
      true)
    (ok true)))

;; delete-profile
;; Permanently removes the caller's on-chain profile.
;; Errors:
;;   u2 - no profile found to delete
(define-public (delete-profile)
  (let (
    (existing (map-get? profiles { owner: tx-sender })))
    (asserts! (is-some existing) (err u2))
    (map-delete profiles { owner: tx-sender })
    (ok true)))

;; ---------------------------------------------------------------------------
;; READ-ONLY FUNCTIONS
;; ---------------------------------------------------------------------------

(define-read-only (get-profile (owner principal))
  (map-get? profiles { owner: owner }))

(define-read-only (has-profile (owner principal))
  (is-some (map-get? profiles { owner: owner })))

(define-read-only (get-total-profiles)
  (var-get total-profiles))
