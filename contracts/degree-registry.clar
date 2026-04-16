;; degree-registry.clar
;; ProofLedger Degree Registry
;; Institutions register degrees with student wallet and document proof

(define-map degrees
  { hash: (buff 32) }
  { institution: principal, student: principal,
    degree-type: (string-ascii 50), field: (string-ascii 100),
    issued-at: uint, graduation-block: uint })

(define-map institution-degrees
  { institution: principal, index: uint }
  { hash: (buff 32) })

(define-map institution-counts
  { institution: principal }
  { count: uint })

(define-data-var total-degrees uint u0)

;; issue-degree: institution registers a degree for a student
;; Errors: u1 = hash already issued
(define-public (issue-degree (hash (buff 32)) (student principal)
                               (degree-type (string-ascii 50))
                               (field (string-ascii 100)))
  (let ((count (default-to u0 (get count (map-get? institution-counts { institution: tx-sender })))))
    (asserts! (is-none (map-get? degrees { hash: hash })) (err u1))
    (map-set degrees { hash: hash }
      { institution: tx-sender, student: student,
        degree-type: degree-type, field: field,
        issued-at: stacks-block-height,
        graduation-block: stacks-block-height })
    (map-set institution-degrees { institution: tx-sender, index: count }
      { hash: hash })
    (map-set institution-counts { institution: tx-sender } { count: (+ count u1) })
    (var-set total-degrees (+ (var-get total-degrees) u1))
    (ok true)))

(define-read-only (get-degree (hash (buff 32)))
  (map-get? degrees { hash: hash }))

(define-read-only (get-institution-count (institution principal))
  (default-to u0 (get count (map-get? institution-counts { institution: institution }))))

(define-read-only (get-total-degrees) (var-get total-degrees))