;; proof-router.clar
;; ProofLedger Proof Router
;; Single entry-point that routes anchor calls to the right sub-contract

(define-map route-log
  { route-id: uint }
  { caller:      principal,
    hash:        (buff 32),
    target:      (string-ascii 30),
    routed-at:   uint,
    success:     bool })

(define-data-var router-admin principal tx-sender)
(define-data-var route-count  uint u0)
(define-data-var default-target (string-ascii 30) "proofleger3")

;; route-anchor: log a routing decision and target contract
;; Errors: u401 = not authorized
(define-public (route-anchor (hash (buff 32)) (target (string-ascii 30)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get router-admin))
                  true) ;; open routing — any caller may record
              (err u401))
    (let ((id (+ (var-get route-count) u1)))
      (map-set route-log { route-id: id }
        { caller:    tx-sender,
          hash:      hash,
          target:    target,
          routed-at: stacks-block-height,
          success:   true })
      (var-set route-count id)
      (ok id))))

;; set-default-target: admin changes the default contract name
(define-public (set-default-target (target (string-ascii 30)))
  (begin
    (asserts! (is-eq tx-sender (var-get router-admin)) (err u401))
    (var-set default-target target)
    (ok target)))

(define-read-only (get-route (route-id uint))
  (map-get? route-log { route-id: route-id }))

(define-read-only (get-default-target) (var-get default-target))
(define-read-only (get-route-count)    (var-get route-count))