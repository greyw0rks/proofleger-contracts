;; auctions.clar
;; ProofLedger Credential Auctions
;; Time-limited auctions for anchored document credentials

(define-map auctions
  { id: uint }
  { seller: principal, proof-hash: (buff 32),
    start-price: uint, current-bid: uint,
    current-bidder: (optional principal),
    end-block: uint, settled: bool })

(define-map bids
  { auction-id: uint, bidder: principal }
  { amount: uint, bid-at: uint })

(define-data-var auction-count uint u0)

;; create-auction: list a credential for auction
(define-public (create-auction (proof-hash (buff 32))
                                 (start-price uint) (duration uint))
  (let ((id (+ (var-get auction-count) u1)))
    (asserts! (> duration u0) (err u1))
    (asserts! (> start-price u0) (err u2))
    (map-set auctions { id: id }
      { seller: tx-sender, proof-hash: proof-hash,
        start-price: start-price, current-bid: u0,
        current-bidder: none,
        end-block: (+ stacks-block-height duration), settled: false })
    (var-set auction-count id)
    (ok id)))

;; place-bid: place a bid on an active auction
;; Errors: u3 = not found, u4 = auction ended, u5 = bid too low, u6 = already highest bidder
(define-public (place-bid (auction-id uint) (amount uint))
  (let ((auction (unwrap! (map-get? auctions { id: auction-id }) (err u3))))
    (asserts! (<= stacks-block-height (get end-block auction)) (err u4))
    (asserts! (> amount (get current-bid auction)) (err u5))
    (asserts! (> amount (get start-price auction)) (err u5))
    (asserts! (not (is-eq (some tx-sender) (get current-bidder auction))) (err u6))
    ;; Refund previous bidder
    (match (get current-bidder auction)
      prev (try! (as-contract (stx-transfer? (get current-bid auction) tx-sender prev)))
      true)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set bids { auction-id: auction-id, bidder: tx-sender }
      { amount: amount, bid-at: stacks-block-height })
    (map-set auctions { id: auction-id }
      (merge auction { current-bid: amount, current-bidder: (some tx-sender) }))
    (ok true)))

;; settle-auction: transfer funds to seller after auction ends
;; Errors: u7 = not ended yet, u8 = already settled, u9 = no bids
(define-public (settle-auction (auction-id uint))
  (let ((auction (unwrap! (map-get? auctions { id: auction-id }) (err u3))))
    (asserts! (> stacks-block-height (get end-block auction)) (err u7))
    (asserts! (not (get settled auction)) (err u8))
    (asserts! (is-some (get current-bidder auction)) (err u9))
    (try! (as-contract (stx-transfer? (get current-bid auction) tx-sender (get seller auction))))
    (map-set auctions { id: auction-id }
      (merge auction { settled: true }))
    (ok true)))

(define-read-only (get-auction (id uint))
  (map-get? auctions { id: id }))