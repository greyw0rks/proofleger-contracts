;; cross-chain-bridge.clar
;; ProofLedger Cross-Chain Bridge Records
;; Track when proofs are anchored on multiple chains

(define-map bridge-records
  { hash: (buff 32), source-chain: (string-ascii 20) }
  { anchor-chain: (string-ascii 20), anchor-address: (string-ascii 100),
    bridged-at: uint, bridger: principal, confirmed: bool })

(define-map hash-chains
  { hash: (buff 32) }
  { chains: (list 5 (string-ascii 20)) })

(define-data-var total-bridges uint u0)

;; record-bridge: log that a hash was anchored on another chain
(define-public (record-bridge (hash (buff 32)) (source-chain (string-ascii 20))
                                (anchor-chain (string-ascii 20))
                                (anchor-address (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? bridge-records { hash: hash, source-chain: source-chain })) (err u1))
    (map-set bridge-records { hash: hash, source-chain: source-chain }
      { anchor-chain: anchor-chain, anchor-address: anchor-address,
        bridged-at: stacks-block-height, bridger: tx-sender, confirmed: false })
    (var-set total-bridges (+ (var-get total-bridges) u1))
    (ok true)))

;; confirm-bridge: mark a bridge record as confirmed
(define-public (confirm-bridge (hash (buff 32)) (source-chain (string-ascii 20)))
  (let ((record (unwrap! (map-get? bridge-records { hash: hash, source-chain: source-chain }) (err u2))))
    (asserts! (is-eq tx-sender (get bridger record)) (err u3))
    (map-set bridge-records { hash: hash, source-chain: source-chain }
      (merge record { confirmed: true }))
    (ok true)))

(define-read-only (get-bridge (hash (buff 32)) (source-chain (string-ascii 20)))
  (map-get? bridge-records { hash: hash, source-chain: source-chain }))

(define-read-only (is-multi-chain (hash (buff 32)) (chain-a (string-ascii 20)) (chain-b (string-ascii 20)))
  (and
    (is-some (map-get? bridge-records { hash: hash, source-chain: chain-a }))
    (is-some (map-get? bridge-records { hash: hash, source-chain: chain-b }))))