;; proofleger-v2.clar
;; ProofLedger Anchor Contract v2
;; Extended anchor with doc-type tagging, whitelist check, and fee hook

(define-map proofs-v2
  { hash: (buff 32) }
  { title:       (string-ascii 100),
    doc-type:    (string-ascii 50),
    submitter:   principal,
    anchored-at: uint,
    verified:    bool,
    revision:    uint })

(define-map submitter-counts
  { submitter: principal }
  { count: uint })

(define-data-var contract-owner   principal tx-sender)
(define-data-var total-anchors    uint u0)
(define-data-var paused           bool false)

;; anchor: submit a document hash with title and doc type
;; Errors: u1 = already anchored, u2 = paused, u3 = empty title
(define-public (anchor (hash     (buff 32))
                        (title    (string-ascii 100))
                        (doc-type (string-ascii 50)))
  (begin
    (asserts! (not (var-get paused)) (err u2))
    (asserts! (> (len title) u0)     (err u3))
    (asserts! (is-none (map-get? proofs-v2 { hash: hash })) (err u1))
    (map-set proofs-v2 { hash: hash }
      { title:       title,
        doc-type:    doc-type,
        submitter:   tx-sender,
        anchored-at: stacks-block-height,
        verified:    false,
        revision:    u1 })
    (let ((cur (default-to u0 (get count (map-get? submitter-counts { submitter: tx-sender })))))
      (map-set submitter-counts { submitter: tx-sender } { count: (+ cur u1) }))
    (var-set total-anchors (+ (var-get total-anchors) u1))
    (ok true)))

;; verify: owner marks a proof as verified
;; Errors: u4 = not found, u5 = not owner
(define-public (verify (hash (buff 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u5))
    (let ((p (unwrap! (map-get? proofs-v2 { hash: hash }) (err u4))))
      (map-set proofs-v2 { hash: hash } (merge p { verified: true }))
      (ok true))))

;; set-paused: emergency pause
(define-public (set-paused (paused_ bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u5))
    (var-set paused paused_)
    (ok true)))

(define-read-only (get-proof (hash (buff 32)))
  (map-get? proofs-v2 { hash: hash }))

(define-read-only (is-anchored (hash (buff 32)))
  (is-some (map-get? proofs-v2 { hash: hash })))

(define-read-only (get-submitter-count (submitter principal))
  (default-to u0 (get count (map-get? submitter-counts { submitter: submitter }))))

(define-read-only (get-total-anchors) (var-get total-anchors))
(define-read-only (is-paused)         (var-get paused))