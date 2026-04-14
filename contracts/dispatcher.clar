;; dispatcher.clar
;; ProofLedger Action Dispatcher
;; Routes document operations to the appropriate handler contract
;; based on document type and action requested

(define-map handlers
  { doc-type: (string-ascii 50), action: (string-ascii 50) }
  { handler-contract: principal, registered-at: uint })

(define-data-var contract-owner principal tx-sender)
(define-data-var handler-count uint u0)

;; register-handler: map a doc-type+action pair to a handler contract
;; Errors: u403 = not owner
(define-public (register-handler (doc-type (string-ascii 50)) (action (string-ascii 50))
                                   (handler-contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (map-set handlers { doc-type: doc-type, action: action }
      { handler-contract: handler-contract, registered-at: stacks-block-height })
    (var-set handler-count (+ (var-get handler-count) u1))
    (ok true)))

;; get-handler: look up the handler for a doc-type+action
(define-read-only (get-handler (doc-type (string-ascii 50)) (action (string-ascii 50)))
  (map-get? handlers { doc-type: doc-type, action: action }))

(define-read-only (has-handler (doc-type (string-ascii 50)) (action (string-ascii 50)))
  (is-some (map-get? handlers { doc-type: doc-type, action: action })))

(define-read-only (get-handler-count)
  (var-get handler-count))