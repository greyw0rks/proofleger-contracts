;; work-history.clar
;; ProofLedger Work History Registry
;; Record verifiable employment records with on-chain proofs

(define-map employment-records
  { employee: principal, index: uint }
  { employer: principal, role: (string-ascii 100),
    start-block: uint, end-block: (optional uint),
    proof-hash: (buff 32), verified: bool })

(define-map employment-count
  { employee: principal }
  { count: uint })

(define-data-var total-records uint u0)

;; add-employment: employee records their own employment with proof
(define-public (add-employment (employer principal) (role (string-ascii 100))
                                (proof-hash (buff 32)))
  (let ((count (default-to u0 (get count (map-get? employment-count { employee: tx-sender })))))
    (map-set employment-records { employee: tx-sender, index: count }
      { employer: employer, role: role,
        start-block: stacks-block-height, end-block: none,
        proof-hash: proof-hash, verified: false })
    (map-set employment-count { employee: tx-sender } { count: (+ count u1) })
    (var-set total-records (+ (var-get total-records) u1))
    (ok count)))

;; verify-employment: employer verifies an employment record
;; Errors: u1 = not found, u2 = not the employer
(define-public (verify-employment (employee principal) (index uint))
  (let ((record (unwrap! (map-get? employment-records { employee: employee, index: index }) (err u1))))
    (asserts! (is-eq tx-sender (get employer record)) (err u2))
    (map-set employment-records { employee: employee, index: index }
      (merge record { verified: true }))
    (ok true)))

;; end-employment: mark a position as ended
(define-public (end-employment (index uint))
  (let ((record (unwrap! (map-get? employment-records { employee: tx-sender, index: index }) (err u1))))
    (map-set employment-records { employee: tx-sender, index: index }
      (merge record { end-block: (some stacks-block-height) }))
    (ok true)))

(define-read-only (get-employment (employee principal) (index uint))
  (map-get? employment-records { employee: employee, index: index }))

(define-read-only (get-employment-count (employee principal))
  (default-to u0 (get count (map-get? employment-count { employee: employee }))))