;; dispatcher.clar
;; ProofLedger Contract Dispatcher
;; Route function calls to the latest or pinned contract version

(define-map routes
  { route-key: (string-ascii 50) }
  { target: principal, version: (string-ascii 20),
    active: bool, updated-at: uint })

(define-data-var dispatcher-owner principal tx-sender)

;; register-route: owner sets a route to a contract
(define-public (register-route (route-key (string-ascii 50))
                                  (target principal)
                                  (version (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get dispatcher-owner)) (err u401))
    (map-set routes { route-key: route-key }
      { target: target, version: version,
        active: true, updated-at: stacks-block-height })
    (ok true)))

;; deactivate-route: disable a route without deleting it
(define-public (deactivate-route (route-key (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get dispatcher-owner)) (err u401))
    (match (map-get? routes { route-key: route-key })
      r (map-set routes { route-key: route-key } (merge r { active: false }))
      true)
    (ok true)))

(define-read-only (get-route (route-key (string-ascii 50)))
  (map-get? routes { route-key: route-key }))

(define-read-only (get-active-target (route-key (string-ascii 50)))
  (match (map-get? routes { route-key: route-key })
    r (if (get active r) (some (get target r)) none)
    none))