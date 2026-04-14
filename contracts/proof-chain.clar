;; proof-chain.clar
;; ProofLedger Proof Chain
;; Link related document hashes in a verifiable chain of evidence

(define-map chains
  { chain-id: uint }
  { creator: principal, title: (string-ascii 100),
    length: uint, created-at: uint })

(define-map chain-links
  { chain-id: uint, index: uint }
  { hash: (buff 32), description: (string-ascii 200),
    added-by: principal, added-at: uint })

(define-data-var chain-count uint u0)

;; create-chain: start a new evidence chain
(define-public (create-chain (title (string-ascii 100)))
  (let ((id (+ (var-get chain-count) u1)))
    (map-set chains { chain-id: id }
      { creator: tx-sender, title: title,
        length: u0, created-at: stacks-block-height })
    (var-set chain-count id)
    (ok id)))

;; add-link: append a document hash to a chain
;; Errors: u1 = chain not found, u2 = not creator
(define-public (add-link (chain-id uint) (hash (buff 32)) (description (string-ascii 200)))
  (let ((chain (unwrap! (map-get? chains { chain-id: chain-id }) (err u1)))
        (idx (get length chain)))
    (asserts! (is-eq tx-sender (get creator chain)) (err u2))
    (map-set chain-links { chain-id: chain-id, index: idx }
      { hash: hash, description: description,
        added-by: tx-sender, added-at: stacks-block-height })
    (map-set chains { chain-id: chain-id }
      (merge chain { length: (+ idx u1) }))
    (ok idx)))

(define-read-only (get-chain (chain-id uint))
  (map-get? chains { chain-id: chain-id }))

(define-read-only (get-link (chain-id uint) (index uint))
  (map-get? chain-links { chain-id: chain-id, index: index }))