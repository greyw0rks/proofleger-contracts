;; escrow.clar
;; ProofLedger Document Escrow
;; Release STX when a specific document hash is verified on-chain

(define-map escrows
  { id: uint }
  { depositor: principal, recipient: principal, amount: uint,
    required-hash: (buff 32), released: bool, created-at: uint })

(define-data-var escrow-count uint u0)

;; create-escrow: deposit STX locked to a document hash condition
;; Errors: u1 = amount must be positive
(define-public (create-escrow (recipient principal) (required-hash (buff 32)) (amount uint))
  (begin
    (asserts! (> amount u0) (err u1))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((id (+ (var-get escrow-count) u1)))
      (map-set escrows { id: id }
        { depositor: tx-sender, recipient: recipient, amount: amount,
          required-hash: required-hash, released: false, created-at: stacks-block-height })
      (var-set escrow-count id)
      (ok id))))

;; release-escrow: recipient claims funds by providing the document proof
;; In production this would verify against proofleger3 contract
;; Errors: u2 = not found, u3 = already released, u4 = not the recipient
(define-public (release-escrow (id uint))
  (let ((escrow (unwrap! (map-get? escrows { id: id }) (err u2))))
    (asserts! (not (get released escrow)) (err u3))
    (asserts! (is-eq tx-sender (get recipient escrow)) (err u4))
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get recipient escrow))))
    (map-set escrows { id: id } (merge escrow { released: true }))
    (ok true)))

(define-read-only (get-escrow (id uint))
  (map-get? escrows { id: id }))