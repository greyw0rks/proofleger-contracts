;; challenges.clar
;; ProofLedger Community Challenges
;; Create challenges requiring specific document proof types

(define-map challenges
  { id: uint }
  { creator: principal, title: (string-ascii 100),
    required-doc-type: (string-ascii 50), reward: uint,
    deadline: uint, completed-by: (optional principal),
    created-at: uint, active: bool })

(define-map challenge-submissions
  { challenge-id: uint, submitter: principal }
  { hash: (buff 32), submitted-at: uint })

(define-data-var challenge-count uint u0)

;; create-challenge: post a challenge requiring proof of specific document type
(define-public (create-challenge (title (string-ascii 100)) (required-doc-type (string-ascii 50))
                                  (reward uint) (duration uint))
  (let ((id (+ (var-get challenge-count) u1)))
    (try! (stx-transfer? reward tx-sender (as-contract tx-sender)))
    (map-set challenges { id: id }
      { creator: tx-sender, title: title, required-doc-type: required-doc-type,
        reward: reward, deadline: (+ stacks-block-height duration),
        completed-by: none, created-at: stacks-block-height, active: true })
    (var-set challenge-count id)
    (ok id)))

;; submit-proof: submit a document hash as challenge proof
;; Errors: u1 = not found, u2 = expired, u3 = already submitted
(define-public (submit-proof (challenge-id uint) (hash (buff 32)))
  (let ((challenge (unwrap! (map-get? challenges { id: challenge-id }) (err u1))))
    (asserts! (get active challenge) (err u2))
    (asserts! (<= stacks-block-height (get deadline challenge)) (err u2))
    (asserts! (is-none (map-get? challenge-submissions { challenge-id: challenge-id, submitter: tx-sender })) (err u3))
    (map-set challenge-submissions { challenge-id: challenge-id, submitter: tx-sender }
      { hash: hash, submitted-at: stacks-block-height })
    (ok true)))

(define-read-only (get-challenge (id uint))
  (map-get? challenges { id: id }))

(define-read-only (get-submission (challenge-id uint) (submitter principal))
  (map-get? challenge-submissions { challenge-id: challenge-id, submitter: submitter }))