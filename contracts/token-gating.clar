;; token-gating.clar
;; ProofLedger Token Gating
;; Gate access to resources based on NFT or credential ownership

(define-map gated-resources
  { resource-id: (string-ascii 100) }
  { owner: principal, title: (string-ascii 100),
    gate-type: (string-ascii 20), required-contract: principal,
    created-at: uint, access-count: uint })

(define-map resource-access-log
  { resource-id: (string-ascii 100), accessor: principal }
  { first-access: uint, access-count: uint })

(define-data-var resource-count uint u0)

;; register-resource: register a gated resource
;; gate-type: "nft" | "credential" | "achievement"
(define-public (register-resource (resource-id (string-ascii 100)) (title (string-ascii 100))
                                    (gate-type (string-ascii 20)) (required-contract principal))
  (begin
    (asserts! (is-none (map-get? gated-resources { resource-id: resource-id })) (err u1))
    (map-set gated-resources { resource-id: resource-id }
      { owner: tx-sender, title: title, gate-type: gate-type,
        required-contract: required-contract,
        created-at: stacks-block-height, access-count: u0 })
    (var-set resource-count (+ (var-get resource-count) u1))
    (ok true)))

;; log-access: log that a principal accessed a gated resource
(define-public (log-access (resource-id (string-ascii 100)))
  (let ((resource (unwrap! (map-get? gated-resources { resource-id: resource-id }) (err u2)))
        (existing (map-get? resource-access-log { resource-id: resource-id, accessor: tx-sender })))
    (map-set resource-access-log { resource-id: resource-id, accessor: tx-sender }
      { first-access: (default-to stacks-block-height (get first-access existing)),
        access-count: (+ (default-to u0 (get access-count existing)) u1) })
    (map-set gated-resources { resource-id: resource-id }
      (merge resource { access-count: (+ (get access-count resource) u1) }))
    (ok true)))

(define-read-only (get-resource (resource-id (string-ascii 100)))
  (map-get? gated-resources { resource-id: resource-id }))

(define-read-only (get-access-log (resource-id (string-ascii 100)) (accessor principal))
  (map-get? resource-access-log { resource-id: resource-id, accessor: accessor }))