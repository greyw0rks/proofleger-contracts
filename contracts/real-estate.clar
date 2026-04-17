;; real-estate.clar
;; ProofLedger Real Estate Registry
;; Anchor property transaction documents with buyer, seller, and property ID

(define-map property-records
  { property-id: (string-ascii 100) }
  { current-owner: principal, last-transfer-hash: (buff 32),
    transfer-count: uint, first-recorded-at: uint })

(define-map transfers
  { hash: (buff 32) }
  { property-id: (string-ascii 100), seller: principal, buyer: principal,
    transfer-at: uint, doc-type: (string-ascii 50) })

(define-data-var total-transfers uint u0)

;; record-transfer: anchor a property document transfer
;; Errors: u1 = hash already recorded
(define-public (record-transfer (hash (buff 32)) (property-id (string-ascii 100))
                                  (buyer principal) (doc-type (string-ascii 50)))
  (begin
    (asserts! (is-none (map-get? transfers { hash: hash })) (err u1))
    (map-set transfers { hash: hash }
      { property-id: property-id, seller: tx-sender, buyer: buyer,
        transfer-at: stacks-block-height, doc-type: doc-type })
    (let ((existing (map-get? property-records { property-id: property-id })))
      (map-set property-records { property-id: property-id }
        { current-owner: buyer,
          last-transfer-hash: hash,
          transfer-count: (+ (default-to u0 (get transfer-count existing)) u1),
          first-recorded-at: (default-to stacks-block-height (get first-recorded-at existing)) }))
    (var-set total-transfers (+ (var-get total-transfers) u1))
    (ok true)))

(define-read-only (get-property (property-id (string-ascii 100)))
  (map-get? property-records { property-id: property-id }))

(define-read-only (get-transfer (hash (buff 32)))
  (map-get? transfers { hash: hash }))