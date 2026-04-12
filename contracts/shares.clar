;; shares.clar
;; ProofLedger Document Shares
;; Represent fractional ownership of anchored documents

(define-fungible-token doc-share)

(define-map document-shares
  { hash: (buff 32) }
  { owner: principal, total-shares: uint, issued-at: uint })

(define-map share-holders
  { hash: (buff 32), holder: principal }
  { shares: uint })

;; issue-shares: mint shares for a document hash
;; Errors: u1 = already issued
(define-public (issue-shares (hash (buff 32)) (total-shares uint))
  (begin
    (asserts! (is-none (map-get? document-shares { hash: hash })) (err u1))
    (asserts! (> total-shares u0) (err u2))
    (try! (ft-mint? doc-share total-shares tx-sender))
    (map-set document-shares { hash: hash }
      { owner: tx-sender, total-shares: total-shares, issued-at: stacks-block-height })
    (map-set share-holders { hash: hash, holder: tx-sender } { shares: total-shares })
    (ok true)))

;; transfer-shares: transfer ownership shares to another wallet
(define-public (transfer-shares (hash (buff 32)) (recipient principal) (amount uint))
  (let ((current (default-to u0 (get shares (map-get? share-holders { hash: hash, holder: tx-sender }))))
        (recipient-current (default-to u0 (get shares (map-get? share-holders { hash: hash, holder: recipient })))))
    (asserts! (>= current amount) (err u3))
    (try! (ft-transfer? doc-share amount tx-sender recipient))
    (map-set share-holders { hash: hash, holder: tx-sender } { shares: (- current amount) })
    (map-set share-holders { hash: hash, holder: recipient } { shares: (+ recipient-current amount) })
    (ok true)))

(define-read-only (get-share-balance (hash (buff 32)) (holder principal))
  (default-to u0 (get shares (map-get? share-holders { hash: hash, holder: holder }))))