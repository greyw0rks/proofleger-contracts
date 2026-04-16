;; certificate-template.clar
;; ProofLedger Certificate Templates
;; Define reusable templates for batch credential issuance

(define-map templates
  { id: uint }
  { creator: principal, name: (string-ascii 100),
    cert-type: (string-ascii 50), description: (string-ascii 200),
    created-at: uint, issue-count: uint, active: bool })

(define-map template-issues
  { template-id: uint, recipient: principal }
  { hash: (buff 32), issued-at: uint })

(define-data-var template-count uint u0)

;; create-template: define a new certificate template
(define-public (create-template (name (string-ascii 100))
                                  (cert-type (string-ascii 50))
                                  (description (string-ascii 200)))
  (let ((id (+ (var-get template-count) u1)))
    (map-set templates { id: id }
      { creator: tx-sender, name: name, cert-type: cert-type,
        description: description, created-at: stacks-block-height,
        issue-count: u0, active: true })
    (var-set template-count id)
    (ok id)))

;; issue-from-template: issue a credential from a template
;; Errors: u1 = template not found, u2 = not creator, u3 = already issued to recipient
(define-public (issue-from-template (template-id uint) (recipient principal) (hash (buff 32)))
  (let ((tmpl (unwrap! (map-get? templates { id: template-id }) (err u1))))
    (asserts! (is-eq tx-sender (get creator tmpl)) (err u2))
    (asserts! (is-none (map-get? template-issues { template-id: template-id, recipient: recipient })) (err u3))
    (map-set template-issues { template-id: template-id, recipient: recipient }
      { hash: hash, issued-at: stacks-block-height })
    (map-set templates { id: template-id }
      (merge tmpl { issue-count: (+ (get issue-count tmpl) u1) }))
    (ok true)))

(define-read-only (get-template (id uint))
  (map-get? templates { id: id }))

(define-read-only (get-issued (template-id uint) (recipient principal))
  (map-get? template-issues { template-id: template-id, recipient: recipient }))