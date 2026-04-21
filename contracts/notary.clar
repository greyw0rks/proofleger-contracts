;; notary.clar
;; ProofLedger Multi-Party Notarization
;; A document hash can be notarized by multiple independent witnesses

(define-map notarizations
  { hash: (buff 32) }
  { initiator: principal, title: (string-ascii 100),
    witness-count: uint, created-at: uint, finalized: bool })

(define-map witness-signatures
  { hash: (buff 32), witness: principal }
  { signed-at: uint, attestation: (string-ascii 100) })

(define-data-var total-notarizations uint u0)

;; initiate-notarization: submitter creates notarization request
;; Errors: u1 = hash already notarized
(define-public (initiate-notarization (hash (buff 32)) (title (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? notarizations { hash: hash })) (err u1))
    (map-set notarizations { hash: hash }
      { initiator: tx-sender, title: title,
        witness-count: u0, created-at: stacks-block-height, finalized: false })
    (var-set total-notarizations (+ (var-get total-notarizations) u1))
    (ok true)))

;; witness-sign: independent party signs the notarization
;; Errors: u2 = not found, u3 = already signed, u4 = initiator cannot self-witness
(define-public (witness-sign (hash (buff 32)) (attestation (string-ascii 100)))
  (let ((n (unwrap! (map-get? notarizations { hash: hash }) (err u2))))
    (asserts! (not (is-eq tx-sender (get initiator n))) (err u4))
    (asserts! (is-none (map-get? witness-signatures { hash: hash, witness: tx-sender })) (err u3))
    (map-set witness-signatures { hash: hash, witness: tx-sender }
      { signed-at: stacks-block-height, attestation: attestation })
    (map-set notarizations { hash: hash }
      (merge n { witness-count: (+ (get witness-count n) u1) }))
    (ok true)))

;; finalize: initiator finalizes notarization once enough witnesses signed
(define-public (finalize (hash (buff 32)))
  (let ((n (unwrap! (map-get? notarizations { hash: hash }) (err u2))))
    (asserts! (is-eq tx-sender (get initiator n)) (err u5))
    (asserts! (>= (get witness-count n) u1) (err u6))
    (map-set notarizations { hash: hash } (merge n { finalized: true }))
    (ok true)))

(define-read-only (get-notarization (hash (buff 32)))
  (map-get? notarizations { hash: hash }))

(define-read-only (get-witness (hash (buff 32)) (witness principal))
  (map-get? witness-signatures { hash: hash, witness: witness }))

(define-read-only (is-finalized (hash (buff 32)))
  (default-to false (get finalized (map-get? notarizations { hash: hash }))))