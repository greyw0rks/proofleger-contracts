;; auctions.clar
;; ProofLedger Document Auctions
;; Auction credential NFTs with time-limited bidding

(define-map auctions
  { id: uint }
  { seller: principal, token-id: uint, min-bid: uint,
    current-bid: uint, current-bidder: (optional principal),
    ends-at: uint, settled: bool })

(define-data-var auction-count uint u0)

;; create-auction: list an NFT for auction
(define-public (create-auction (token-id uint) (min-bid uint) (duration uint))
  (let ((id (+ (var-get auction-count) u1)))
    (asserts! (> min-bid u0) (err u1))
    (asserts! (> duration u0) (err u2))
    (map-set auctions { id: id }
      { seller: tx-sender, token-id: token-id, min-bid: min-bid,
        current-bid: u0, current-bidder: none,
        ends-at: (+ stacks-block-height duration), settled: false })
    (var-set auction-count id)
    (ok id)))

;; place-bid: bid on an active auction
;; Errors: u3 = not found, u4 = auction ended, u5 = bid too low
(define-public (place-bid (auction-id uint) (amount uint))
  (let ((auction (unwrap! (map-get? auctions { id: auction-id }) (err u3))))
    (asserts! (<= stacks-block-height (get ends-at auction)) (err u4))
    (asserts! (> amount (get current-bid auction)) (err u5))
    (asserts! (>= amount (get min-bid auction)) (err u5))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set auctions { id: auction-id }
      (merge auction { current-bid: amount, current-bidder: (some tx-sender) }))
    (ok true)))

(define-read-only (get-auction (id uint))
  (map-get? auctions { id: id }))