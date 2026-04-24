;; endorsements.clar
;; ProofLedger Proof Endorsements
;; Allow wallets to endorse specific document proofs

(define-map endorsements
  { hash: (buff 32), endorser: principal }
  { endorsed-at: uint, comment: (string-ascii 100), weight: uint })

(define-map endorsement-counts
  { hash: (buff 32) }
  { total: uint, total-weight: uint })

;; endorse: add an endorsement to a document proof
;; Errors: u1 = already endorsed, u2 = cannot self-endorse
(define-public (endorse (hash (buff 32)) (comment (string-ascii 100)) (weight uint))
  (begin
    (asserts! (is-none (map-get? endorsements { hash: hash, endorser: tx-sender })) (err u1))
    (map-set endorsements { hash: hash, endorser: tx-sender }
      { endorsed-at: stacks-block-height,
        comment: comment,
        weight: (if (> weight u0) weight u1) })
    (let ((counts (default-to { total: u0, total-weight: u0 }
                   (map-get? endorsement-counts { hash: hash }))))
      (map-set endorsement-counts { hash: hash }
        { total: (+ (get total counts) u1),
          total-weight: (+ (get total-weight counts) (if (> weight u0) weight u1)) }))
    (ok true)))

;; revoke-endorsement: endorser removes their endorsement
;; Errors: u3 = endorsement not found
(define-public (revoke-endorsement (hash (buff 32)))
  (let ((e (unwrap! (map-get? endorsements { hash: hash, endorser: tx-sender }) (err u3)))
        (counts (default-to { total: u0, total-weight: u0 }
                  (map-get? endorsement-counts { hash: hash }))))
    (map-delete endorsements { hash: hash, endorser: tx-sender })
    (map-set endorsement-counts { hash: hash }
      { total: (if (> (get total counts) u0) (- (get total counts) u1) u0),
        total-weight: (if (>= (get total-weight counts) (get weight e))
                        (- (get total-weight counts) (get weight e)) u0) })
    (ok true)))

(define-read-only (get-endorsement (hash (buff 32)) (endorser principal))
  (map-get? endorsements { hash: hash, endorser: endorser }))

(define-read-only (get-endorsement-count (hash (buff 32)))
  (default-to u0 (get total (map-get? endorsement-counts { hash: hash }))))

(define-read-only (get-endorsement-weight (hash (buff 32)))
  (default-to u0 (get total-weight (map-get? endorsement-counts { hash: hash }))))