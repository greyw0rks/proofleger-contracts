;; certifier.clar
;; ProofLedger Batch Certifier
;; Allows institutions to certify multiple documents in one transaction

(define-map certifications
  { certifier: principal, hash: (buff 32) }
  { certified-at: uint, batch-id: uint, cert-type: (string-ascii 50) })

(define-map batch-info
  { certifier: principal, batch-id: uint }
  { count: uint, created-at: uint, description: (string-ascii 200) })

(define-map certifier-batches
  { certifier: principal }
  { batch-count: uint })

;; create-batch: start a new certification batch
(define-public (create-batch (description (string-ascii 200)))
  (let ((batch-count (default-to u0 (get batch-count (map-get? certifier-batches { certifier: tx-sender }))))
        (new-id (+ batch-count u1)))
    (map-set batch-info { certifier: tx-sender, batch-id: new-id }
      { count: u0, created-at: stacks-block-height, description: description })
    (map-set certifier-batches { certifier: tx-sender } { batch-count: new-id })
    (ok new-id)))

;; certify: add a document to a certification batch
;; Errors: u1 = already certified, u2 = batch not found
(define-public (certify (hash (buff 32)) (batch-id uint) (cert-type (string-ascii 50)))
  (let ((batch (unwrap! (map-get? batch-info { certifier: tx-sender, batch-id: batch-id }) (err u2))))
    (asserts! (is-none (map-get? certifications { certifier: tx-sender, hash: hash })) (err u1))
    (map-set certifications { certifier: tx-sender, hash: hash }
      { certified-at: stacks-block-height, batch-id: batch-id, cert-type: cert-type })
    (map-set batch-info { certifier: tx-sender, batch-id: batch-id }
      (merge batch { count: (+ (get count batch) u1) }))
    (ok true)))

(define-read-only (is-certified (certifier principal) (hash (buff 32)))
  (is-some (map-get? certifications { certifier: certifier, hash: hash })))