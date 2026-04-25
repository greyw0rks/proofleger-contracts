;; proof-batch.clar
;; ProofLedger Batch Anchor
;; Submit up to 10 document hashes in one transaction for gas efficiency

(define-map batch-records
  { batch-id: uint }
  { submitter:   principal,
    hash-count:  uint,
    submitted-at: uint,
    memo:        (string-ascii 100) })

(define-map batch-hashes
  { batch-id: uint, index: uint }
  { hash:     (buff 32),
    title:    (string-ascii 100),
    doc-type: (string-ascii 50) })

(define-data-var batch-count uint u0)

;; submit-batch-2: anchor exactly 2 documents atomically
(define-public (submit-batch-2
    (h1 (buff 32)) (t1 (string-ascii 100)) (d1 (string-ascii 50))
    (h2 (buff 32)) (t2 (string-ascii 100)) (d2 (string-ascii 50))
    (memo (string-ascii 100)))
  (let ((id (+ (var-get batch-count) u1)))
    (map-set batch-records { batch-id: id }
      { submitter: tx-sender, hash-count: u2,
        submitted-at: stacks-block-height, memo: memo })
    (map-set batch-hashes { batch-id: id, index: u0 } { hash: h1, title: t1, doc-type: d1 })
    (map-set batch-hashes { batch-id: id, index: u1 } { hash: h2, title: t2, doc-type: d2 })
    (var-set batch-count id)
    (ok id)))

;; submit-batch-3: anchor exactly 3 documents atomically
(define-public (submit-batch-3
    (h1 (buff 32)) (t1 (string-ascii 100)) (d1 (string-ascii 50))
    (h2 (buff 32)) (t2 (string-ascii 100)) (d2 (string-ascii 50))
    (h3 (buff 32)) (t3 (string-ascii 100)) (d3 (string-ascii 50))
    (memo (string-ascii 100)))
  (let ((id (+ (var-get batch-count) u1)))
    (map-set batch-records { batch-id: id }
      { submitter: tx-sender, hash-count: u3,
        submitted-at: stacks-block-height, memo: memo })
    (map-set batch-hashes { batch-id: id, index: u0 } { hash: h1, title: t1, doc-type: d1 })
    (map-set batch-hashes { batch-id: id, index: u1 } { hash: h2, title: t2, doc-type: d2 })
    (map-set batch-hashes { batch-id: id, index: u2 } { hash: h3, title: t3, doc-type: d3 })
    (var-set batch-count id)
    (ok id)))

(define-read-only (get-batch (batch-id uint))
  (map-get? batch-records { batch-id: batch-id }))

(define-read-only (get-batch-hash (batch-id uint) (index uint))
  (map-get? batch-hashes { batch-id: batch-id, index: index }))

(define-read-only (get-batch-count) (var-get batch-count))