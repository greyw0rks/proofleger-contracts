;; bulk-attest.clar
;; ProofLedger Bulk Attestation
;; Attest up to 5 credential hashes in a single transaction

(define-map bulk-batches
  { batch-id: uint }
  { attester:      principal,
    hash-count:    uint,
    submitted-at:  uint,
    memo:          (string-ascii 100) })

(define-map bulk-hashes
  { batch-id: uint, index: uint }
  { hash:    (buff 32),
    note:    (string-ascii 80) })

(define-data-var batch-count uint u0)

;; attest-2: attest exactly 2 hashes in one call
(define-public (attest-2
    (h1 (buff 32)) (n1 (string-ascii 80))
    (h2 (buff 32)) (n2 (string-ascii 80))
    (memo (string-ascii 100)))
  (let ((id (+ (var-get batch-count) u1)))
    (map-set bulk-batches { batch-id: id }
      { attester: tx-sender, hash-count: u2,
        submitted-at: stacks-block-height, memo: memo })
    (map-set bulk-hashes { batch-id: id, index: u0 } { hash: h1, note: n1 })
    (map-set bulk-hashes { batch-id: id, index: u1 } { hash: h2, note: n2 })
    (var-set batch-count id)
    (ok id)))

;; attest-3: attest exactly 3 hashes in one call
(define-public (attest-3
    (h1 (buff 32)) (n1 (string-ascii 80))
    (h2 (buff 32)) (n2 (string-ascii 80))
    (h3 (buff 32)) (n3 (string-ascii 80))
    (memo (string-ascii 100)))
  (let ((id (+ (var-get batch-count) u1)))
    (map-set bulk-batches { batch-id: id }
      { attester: tx-sender, hash-count: u3,
        submitted-at: stacks-block-height, memo: memo })
    (map-set bulk-hashes { batch-id: id, index: u0 } { hash: h1, note: n1 })
    (map-set bulk-hashes { batch-id: id, index: u1 } { hash: h2, note: n2 })
    (map-set bulk-hashes { batch-id: id, index: u2 } { hash: h3, note: n3 })
    (var-set batch-count id)
    (ok id)))

(define-read-only (get-batch (batch-id uint))
  (map-get? bulk-batches { batch-id: batch-id }))

(define-read-only (get-hash (batch-id uint) (index uint))
  (map-get? bulk-hashes { batch-id: batch-id, index: index }))

(define-read-only (get-batch-count) (var-get batch-count))