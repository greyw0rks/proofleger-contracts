;; cross-chain-bridge.clar
;; ProofLedger Cross-Chain Bridge Registry
;; Track bridge relay operators and their message relay history

(define-map relay-operators
  { operator: principal }
  { registered-at: uint,
    active:        bool,
    relay-count:   uint,
    label:         (string-ascii 60) })

(define-map relay-messages
  { message-id: uint }
  { operator:    principal,
    source-chain: (string-ascii 20),
    dest-chain:   (string-ascii 20),
    payload-hash: (buff 32),
    relayed-at:   uint,
    confirmed:    bool })

(define-data-var bridge-admin  principal tx-sender)
(define-data-var message-count uint u0)

;; register-operator: admin registers a trusted relay operator
;; Errors: u401 = not admin
(define-public (register-operator (operator principal) (label (string-ascii 60)))
  (begin
    (asserts! (is-eq tx-sender (var-get bridge-admin)) (err u401))
    (map-set relay-operators { operator: operator }
      { registered-at: stacks-block-height, active: true,
        relay-count: u0, label: label })
    (ok true)))

;; relay: operator submits a cross-chain message
;; Errors: u1 = not a registered operator
(define-public (relay (source-chain (string-ascii 20))
                       (dest-chain   (string-ascii 20))
                       (payload-hash (buff 32)))
  (let ((op (unwrap! (map-get? relay-operators { operator: tx-sender }) (err u1))))
    (asserts! (get active op) (err u1))
    (let ((id (+ (var-get message-count) u1)))
      (map-set relay-messages { message-id: id }
        { operator:     tx-sender,
          source-chain: source-chain,
          dest-chain:   dest-chain,
          payload-hash: payload-hash,
          relayed-at:   stacks-block-height,
          confirmed:    false })
      (map-set relay-operators { operator: tx-sender }
        (merge op { relay-count: (+ (get relay-count op) u1) }))
      (var-set message-count id)
      (ok id))))

;; confirm: admin confirms a relay message
;; Errors: u401 = not admin, u2 = not found
(define-public (confirm (message-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get bridge-admin)) (err u401))
    (let ((m (unwrap! (map-get? relay-messages { message-id: message-id }) (err u2))))
      (map-set relay-messages { message-id: message-id }
        (merge m { confirmed: true }))
      (ok true))))

(define-read-only (get-message (message-id uint))
  (map-get? relay-messages { message-id: message-id }))

(define-read-only (get-operator (operator principal))
  (map-get? relay-operators { operator: operator }))

(define-read-only (get-message-count) (var-get message-count))