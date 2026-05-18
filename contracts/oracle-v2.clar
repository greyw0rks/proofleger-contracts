;; oracle-v2.clar
;; Multi-source price oracle with median aggregation and staleness checks
;; Errors:
;;   u100 - not authorized feeder
;;   u101 - asset not found
;;   u102 - price stale
;;   u103 - insufficient sources

(define-constant CONTRACT-OWNER tx-sender)
(define-constant STALE-BLOCKS u20)
(define-constant MIN-SOURCES u2)

(define-map feeders principal { active: bool, submissions: uint })
(define-map price-feeds
  { asset: (string-ascii 10), feeder: principal }
  { price: uint, submitted-at: uint })

(define-map aggregated-prices
  { asset: (string-ascii 10) }
  { price: uint, sources: uint, updated-at: uint })

(define-public (authorize-feeder (feeder principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u100))
    (ok (map-set feeders feeder { active: true, submissions: u0 }))))

(define-public (submit-price (asset (string-ascii 10)) (price uint))
  (let ((feeder (unwrap! (map-get? feeders tx-sender) (err u100))))
    (asserts! (get active feeder) (err u100))
    (map-set price-feeds { asset: asset, feeder: tx-sender }
      { price: price, submitted-at: block-height })
    (map-set feeders tx-sender (merge feeder { submissions: (+ (get submissions feeder) u1) }))
    (ok price)))

(define-public (aggregate-price (asset (string-ascii 10)) (prices (list 5 uint)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u100))
    (asserts! (>= (len prices) MIN-SOURCES) (err u103))
    (let ((median (unwrap! (element-at prices (/ (len prices) u2)) (err u103))))
      (map-set aggregated-prices { asset: asset }
        { price: median, sources: (len prices), updated-at: block-height })
      (ok median))))

(define-read-only (get-price (asset (string-ascii 10)))
  (match (map-get? aggregated-prices { asset: asset })
    feed
    (if (<= (- block-height (get updated-at feed)) STALE-BLOCKS)
      (ok (get price feed))
      (err u102))
    (err u101)))

(define-read-only (get-feeder-submissions (feeder principal))
  (match (map-get? feeders feeder)
    f (get submissions f)
    u0))
