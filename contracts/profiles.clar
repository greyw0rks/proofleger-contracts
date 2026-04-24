;; profiles.clar
;; ProofLedger Wallet Profiles
;; On-chain profile data linked to proof anchoring activity

(define-map profiles
  { owner: principal }
  { display-name: (string-ascii 50),
    bio:           (string-ascii 200),
    website:       (string-ascii 100),
    proof-count:   uint,
    updated-at:    uint,
    public:        bool })

(define-map profile-stats
  { owner: principal }
  { total-anchors: uint, total-attests: uint,
    total-endorsements: uint, reputation: uint })

(define-data-var total-profiles uint u0)

;; create-profile: register a public profile
;; Errors: u1 = profile already exists
(define-public (create-profile (display-name (string-ascii 50))
                                  (bio (string-ascii 200))
                                  (website (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? profiles { owner: tx-sender })) (err u1))
    (map-set profiles { owner: tx-sender }
      { display-name: display-name, bio: bio, website: website,
        proof-count: u0, updated-at: stacks-block-height, public: true })
    (map-set profile-stats { owner: tx-sender }
      { total-anchors: u0, total-attests: u0, total-endorsements: u0, reputation: u0 })
    (var-set total-profiles (+ (var-get total-profiles) u1))
    (ok true)))

;; update-profile: update name, bio, website
;; Errors: u2 = profile not found
(define-public (update-profile (display-name (string-ascii 50))
                                  (bio (string-ascii 200))
                                  (website (string-ascii 100)))
  (let ((p (unwrap! (map-get? profiles { owner: tx-sender }) (err u2))))
    (map-set profiles { owner: tx-sender }
      (merge p { display-name: display-name, bio: bio,
                 website: website, updated-at: stacks-block-height }))
    (ok true)))

;; increment-anchors: called when user anchors a document
(define-public (increment-anchors (owner principal))
  (let ((stats (default-to { total-anchors:u0, total-attests:u0,
                              total-endorsements:u0, reputation:u0 }
                 (map-get? profile-stats { owner: owner }))))
    (map-set profile-stats { owner: owner }
      (merge stats { total-anchors: (+ (get total-anchors stats) u1),
                     reputation: (+ (get reputation stats) u10) }))
    (ok true)))

(define-read-only (get-profile (owner principal))
  (map-get? profiles { owner: owner }))

(define-read-only (get-stats (owner principal))
  (map-get? profile-stats { owner: owner }))

(define-read-only (has-profile (owner principal))
  (is-some (map-get? profiles { owner: owner })))