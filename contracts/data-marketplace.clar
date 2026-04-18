;; data-marketplace.clar
;; ProofLedger Data Marketplace
;; List and purchase access to anchored, verified datasets

(define-map listings
  { listing-id: uint }
  { seller: principal, data-hash: (buff 32),
    title: (string-ascii 100), description: (string-ascii 300),
    price: uint, access-count: uint, created-at: uint, active: bool })

(define-map access-grants
  { listing-id: uint, buyer: principal }
  { purchased-at: uint, tx-block: uint })

(define-data-var listing-count uint u0)

;; create-listing: seller lists a dataset for purchase
(define-public (create-listing (data-hash (buff 32)) (title (string-ascii 100))
                                (description (string-ascii 300)) (price uint))
  (let ((id (+ (var-get listing-count) u1)))
    (asserts! (> price u0) (err u1))
    (map-set listings { listing-id: id }
      { seller: tx-sender, data-hash: data-hash, title: title,
        description: description, price: price,
        access-count: u0, created-at: stacks-block-height, active: true })
    (var-set listing-count id)
    (ok id)))

;; purchase-access: buyer purchases access to a dataset
;; Errors: u2 = not found, u3 = not active, u4 = already purchased
(define-public (purchase-access (listing-id uint))
  (let ((listing (unwrap! (map-get? listings { listing-id: listing-id }) (err u2))))
    (asserts! (get active listing) (err u3))
    (asserts! (is-none (map-get? access-grants { listing-id: listing-id, buyer: tx-sender })) (err u4))
    (try! (stx-transfer? (get price listing) tx-sender (get seller listing)))
    (map-set access-grants { listing-id: listing-id, buyer: tx-sender }
      { purchased-at: stacks-block-height, tx-block: stacks-block-height })
    (map-set listings { listing-id: listing-id }
      (merge listing { access-count: (+ (get access-count listing) u1) }))
    (ok true)))

(define-read-only (has-access (listing-id uint) (buyer principal))
  (is-some (map-get? access-grants { listing-id: listing-id, buyer: buyer })))

(define-read-only (get-listing (listing-id uint))
  (map-get? listings { listing-id: listing-id }))