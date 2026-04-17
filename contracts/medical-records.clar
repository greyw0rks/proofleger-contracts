;; medical-records.clar
;; ProofLedger Medical Record Anchoring
;; Anchor medical document hashes with provider and patient wallet links
;; Note: only hashes stored on-chain, no actual medical data

(define-map medical-records
  { hash: (buff 32) }
  { provider: principal, patient: principal,
    record-type: (string-ascii 50), issued-at: uint,
    patient-consented: bool })

(define-map patient-records
  { patient: principal, index: uint }
  { hash: (buff 32) })

(define-map patient-record-counts
  { patient: principal }
  { count: uint })

(define-data-var total-records uint u0)

;; anchor-record: provider anchors a medical record hash
;; Errors: u1 = hash already anchored
(define-public (anchor-record (hash (buff 32)) (patient principal)
                                (record-type (string-ascii 50)))
  (let ((count (default-to u0 (get count (map-get? patient-record-counts { patient: patient })))))
    (asserts! (is-none (map-get? medical-records { hash: hash })) (err u1))
    (map-set medical-records { hash: hash }
      { provider: tx-sender, patient: patient,
        record-type: record-type, issued-at: stacks-block-height,
        patient-consented: false })
    (map-set patient-records { patient: patient, index: count } { hash: hash })
    (map-set patient-record-counts { patient: patient } { count: (+ count u1) })
    (var-set total-records (+ (var-get total-records) u1))
    (ok true)))

;; grant-consent: patient explicitly consents to a record
(define-public (grant-consent (hash (buff 32)))
  (let ((record (unwrap! (map-get? medical-records { hash: hash }) (err u2))))
    (asserts! (is-eq tx-sender (get patient record)) (err u3))
    (map-set medical-records { hash: hash }
      (merge record { patient-consented: true }))
    (ok true)))

(define-read-only (get-record (hash (buff 32)))
  (map-get? medical-records { hash: hash }))

(define-read-only (get-patient-count (patient principal))
  (default-to u0 (get count (map-get? patient-record-counts { patient: patient }))))