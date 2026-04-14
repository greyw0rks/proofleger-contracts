;; document-updates.clar
;; ProofLedger Document Version Tracker
;; Track when documents are superseded by newer versions

(define-map updates
  { old-hash: (buff 32) }
  { new-hash: (buff 32), updater: principal,
    updated-at: uint, reason: (string-ascii 100) })

(define-map document-history
  { latest-hash: (buff 32) }
  { original-hash: (buff 32), version: uint })

(define-data-var total-updates uint u0)

;; supersede: declare that a new document hash replaces an old one
;; Errors: u1 = already superseded, u2 = cannot supersede self
(define-public (supersede (old-hash (buff 32)) (new-hash (buff 32)) (reason (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? updates { old-hash: old-hash })) (err u1))
    (asserts! (not (is-eq old-hash new-hash)) (err u2))
    (map-set updates { old-hash: old-hash }
      { new-hash: new-hash, updater: tx-sender,
        updated-at: stacks-block-height, reason: reason })
    (var-set total-updates (+ (var-get total-updates) u1))
    (ok true)))

(define-read-only (get-update (old-hash (buff 32)))
  (map-get? updates { old-hash: old-hash }))

(define-read-only (is-superseded (hash (buff 32)))
  (is-some (map-get? updates { old-hash: hash })))

(define-read-only (get-total-updates) (var-get total-updates))