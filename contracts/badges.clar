;; badges.clar
;; ProofLedger Community Badge System
;; Anyone can create and issue badges to any wallet

(define-map badge-definitions
  { id: (string-ascii 50) }
  { creator: principal, name: (string-ascii 100), description: (string-ascii 200), created-at: uint })

(define-map issued-badges
  { recipient: principal, badge-id: (string-ascii 50), issuer: principal }
  { issued-at: uint })

(define-map badge-count
  { recipient: principal }
  { count: uint })

;; create-badge: define a new badge type
;; Errors: u1 = badge ID already exists
(define-public (create-badge (id (string-ascii 50)) (name (string-ascii 100)) (description (string-ascii 200)))
  (begin
    (asserts! (is-none (map-get? badge-definitions { id: id })) (err u1))
    (map-set badge-definitions { id: id }
      { creator: tx-sender, name: name, description: description, created-at: stacks-block-height })
    (ok true)))

;; issue-badge: award a badge to a recipient
;; Errors: u2 = badge not found, u3 = already issued by this issuer
(define-public (issue-badge (recipient principal) (badge-id (string-ascii 50)))
  (let ((count (default-to u0 (get count (map-get? badge-count { recipient: recipient })))))
    (asserts! (is-some (map-get? badge-definitions { id: badge-id })) (err u2))
    (asserts! (is-none (map-get? issued-badges { recipient: recipient, badge-id: badge-id, issuer: tx-sender })) (err u3))
    (map-set issued-badges { recipient: recipient, badge-id: badge-id, issuer: tx-sender } { issued-at: stacks-block-height })
    (map-set badge-count { recipient: recipient } { count: (+ count u1) })
    (ok true)))

(define-read-only (has-badge (recipient principal) (badge-id (string-ascii 50)) (issuer principal))
  (is-some (map-get? issued-badges { recipient: recipient, badge-id: badge-id, issuer: issuer })))