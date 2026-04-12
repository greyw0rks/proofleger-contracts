# ProofLedger Auctions

The `auctions.clar` contract enables time-limited bidding on credential NFTs.

## Create an Auction

```clarity
(contract-call? .auctions create-auction
  u1          ;; NFT token ID
  u1000000    ;; minimum bid (1 STX)
  u1008)      ;; duration (~1 week)
;; Returns: (ok auction-id)
```

## Place a Bid

```clarity
(contract-call? .auctions place-bid u1 u2000000)
;; Bid 2 STX on auction #1
```

## Read Auction Status

```clarity
(contract-call? .auctions get-auction u1)
;; Returns: { seller, token-id, min-bid, current-bid,
;;            current-bidder, ends-at, settled }
```