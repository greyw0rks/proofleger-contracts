;; supply-chain.clar
;; ProofLedger Supply Chain
;; Track documents through multi-step supply chain processes

(define-map shipments
  { shipment-id: (string-ascii 50) }
  { initiator: principal, origin: (string-ascii 100),
    destination: (string-ascii 100), step-count: uint,
    created-at: uint, completed: bool })

(define-map shipment-steps
  { shipment-id: (string-ascii 50), step: uint }
  { actor: principal, action: (string-ascii 100),
    doc-hash: (buff 32), completed-at: uint })

(define-data-var total-shipments uint u0)

;; create-shipment: initiate a new supply chain document trail
;; Errors: u1 = shipment ID already exists
(define-public (create-shipment (shipment-id (string-ascii 50))
                                  (origin (string-ascii 100))
                                  (destination (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? shipments { shipment-id: shipment-id })) (err u1))
    (map-set shipments { shipment-id: shipment-id }
      { initiator: tx-sender, origin: origin, destination: destination,
        step-count: u0, created-at: stacks-block-height, completed: false })
    (var-set total-shipments (+ (var-get total-shipments) u1))
    (ok true)))

;; add-step: add a supply chain event with document proof
;; Errors: u2 = shipment not found, u3 = already completed
(define-public (add-step (shipment-id (string-ascii 50)) (action (string-ascii 100))
                          (doc-hash (buff 32)))
  (let ((shipment (unwrap! (map-get? shipments { shipment-id: shipment-id }) (err u2)))
        (step (get step-count shipment)))
    (asserts! (not (get completed shipment)) (err u3))
    (map-set shipment-steps { shipment-id: shipment-id, step: step }
      { actor: tx-sender, action: action,
        doc-hash: doc-hash, completed-at: stacks-block-height })
    (map-set shipments { shipment-id: shipment-id }
      (merge shipment { step-count: (+ step u1) }))
    (ok step)))

;; complete-shipment: mark shipment as delivered
(define-public (complete-shipment (shipment-id (string-ascii 50)))
  (let ((shipment (unwrap! (map-get? shipments { shipment-id: shipment-id }) (err u2))))
    (asserts! (is-eq tx-sender (get initiator shipment)) (err u4))
    (map-set shipments { shipment-id: shipment-id }
      (merge shipment { completed: true }))
    (ok true)))

(define-read-only (get-shipment (shipment-id (string-ascii 50)))
  (map-get? shipments { shipment-id: shipment-id }))

(define-read-only (get-step (shipment-id (string-ascii 50)) (step uint))
  (map-get? shipment-steps { shipment-id: shipment-id, step: step }))