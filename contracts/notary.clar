;; notary.clar
;; ProofLedger On-Chain Notary
;; Documents can be notarized with multiple witness signatures

(define-map notarizations
  { hash: (buff 32) }
  { notary: principal, notarized-at: uint, description: (string-ascii 200), witness-count: uint })

(define-map witnesses
  { hash: (buff 32), witness: principal }
  { signed-at: uint, statement: (string-ascii 100) })

(define-map witness-index
  { hash: (buff 32), index: uint }
  { witness: principal })

;; notarize: create a notarization record for a document hash
;; Errors: u1 = already notarized
(define-public (notarize (hash (buff 32)) (description (string-ascii 200)))
  (begin
    (asserts! (is-none (map-get? notarizations { hash: hash })) (err u1))
    (map-set notarizations { hash: hash }
      { notary: tx-sender, notarized-at: stacks-block-height,
        description: description, witness-count: u0 })
    (ok true)))

;; add-witness: add a witness signature to a notarized document
;; Errors: u2 = not notarized, u3 = already witnessed by this address
(define-public (add-witness (hash (buff 32)) (statement (string-ascii 100)))
  (let ((notary (unwrap! (map-get? notarizations { hash: hash }) (err u2)))
        (count (get witness-count notary)))
    (asserts! (is-none (map-get? witnesses { hash: hash, witness: tx-sender })) (err u3))
    (map-set witnesses { hash: hash, witness: tx-sender }
      { signed-at: stacks-block-height, statement: statement })
    (map-set witness-index { hash: hash, index: count } { witness: tx-sender })
    (map-set notarizations { hash: hash }
      (merge notary { witness-count: (+ count u1) }))
    (ok true)))

(define-read-only (get-notarization (hash (buff 32)))
  (map-get? notarizations { hash: hash }))

(define-read-only (get-witness (hash (buff 32)) (witness principal))
  (map-get? witnesses { hash: hash, witness: witness }))

(define-read-only (is-notarized (hash (buff 32)))
  (is-some (map-get? notarizations { hash: hash })))