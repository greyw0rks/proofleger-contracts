;; snapshots.clar
;; ProofLedger State Snapshots
;; Record periodic protocol metrics on-chain for public analytics

(define-map snapshots
  { epoch: uint }
  { total-docs: uint, total-wallets: uint, total-attestations: uint,
    total-nfts: uint, recorded-at: uint, recorder: principal })

(define-data-var latest-epoch uint u0)
(define-data-var snapshot-count uint u0)

;; record-snapshot: store a new protocol metrics snapshot
(define-public (record-snapshot (total-docs uint) (total-wallets uint)
                                 (total-attestations uint) (total-nfts uint))
  (let ((epoch (+ (var-get snapshot-count) u1)))
    (map-set snapshots { epoch: epoch }
      { total-docs: total-docs, total-wallets: total-wallets,
        total-attestations: total-attestations, total-nfts: total-nfts,
        recorded-at: stacks-block-height, recorder: tx-sender })
    (var-set snapshot-count epoch)
    (var-set latest-epoch epoch)
    (ok epoch)))

(define-read-only (get-snapshot (epoch uint))
  (map-get? snapshots { epoch: epoch }))

(define-read-only (get-latest-snapshot)
  (map-get? snapshots { epoch: (var-get latest-epoch) }))

(define-read-only (get-snapshot-count)
  (var-get snapshot-count))