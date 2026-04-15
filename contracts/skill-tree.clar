;; skill-tree.clar
;; ProofLedger Skill Tree
;; Track and endorse specific skills linked to credential proofs

(define-map skills
  { owner: principal, skill: (string-ascii 50) }
  { level: uint, first-proof: (buff 32),
    endorsements: uint, last-updated: uint })

(define-map skill-endorsements
  { owner: principal, skill: (string-ascii 50), endorser: principal }
  { endorsed-at: uint })

(define-map skill-proofs
  { owner: principal, skill: (string-ascii 50), index: uint }
  { hash: (buff 32), added-at: uint })

;; add-skill: declare a skill with supporting document proof
;; Errors: u1 = skill already added
(define-public (add-skill (skill (string-ascii 50)) (proof-hash (buff 32)))
  (begin
    (asserts! (is-none (map-get? skills { owner: tx-sender, skill: skill })) (err u1))
    (map-set skills { owner: tx-sender, skill: skill }
      { level: u1, first-proof: proof-hash,
        endorsements: u0, last-updated: stacks-block-height })
    (map-set skill-proofs { owner: tx-sender, skill: skill, index: u0 }
      { hash: proof-hash, added-at: stacks-block-height })
    (ok true)))

;; endorse-skill: endorse someone else skill
;; Errors: u2 = skill not found, u3 = already endorsed, u4 = self-endorse
(define-public (endorse-skill (owner principal) (skill (string-ascii 50)))
  (let ((s (unwrap! (map-get? skills { owner: owner, skill: skill }) (err u2))))
    (asserts! (not (is-eq tx-sender owner)) (err u4))
    (asserts! (is-none (map-get? skill-endorsements { owner: owner, skill: skill, endorser: tx-sender })) (err u3))
    (map-set skill-endorsements { owner: owner, skill: skill, endorser: tx-sender }
      { endorsed-at: stacks-block-height })
    (map-set skills { owner: owner, skill: skill }
      (merge s { endorsements: (+ (get endorsements s) u1) }))
    (ok true)))

(define-read-only (get-skill (owner principal) (skill (string-ascii 50)))
  (map-get? skills { owner: owner, skill: skill }))

(define-read-only (is-endorsed-by (owner principal) (skill (string-ascii 50)) (endorser principal))
  (is-some (map-get? skill-endorsements { owner: owner, skill: skill, endorser: endorser })))