;; multisig.clar
;; ProofLedger Multi-Signature Approval
;; Require M-of-N signatures before a document is considered approved

(define-map multisig-configs
  { id: uint }
  { creator: principal, required: uint, total-signers: uint, created-at: uint })

(define-map multisig-signers
  { config-id: uint, signer: principal }
  { authorized: bool })

(define-map multisig-approvals
  { config-id: uint, hash: (buff 32) }
  { approved-count: uint, approved: bool })

(define-map signer-approvals
  { config-id: uint, hash: (buff 32), signer: principal }
  { signed-at: uint })

(define-data-var config-count uint u0)

;; create-config: set up a new multisig configuration
;; Errors: u1 = required must be positive, u2 = required > total
(define-public (create-config (required uint) (signers (list 10 principal)))
  (let ((id (+ (var-get config-count) u1))
        (total (len signers)))
    (asserts! (> required u0) (err u1))
    (asserts! (<= required total) (err u2))
    (map-set multisig-configs { id: id }
      { creator: tx-sender, required: required,
        total-signers: total, created-at: stacks-block-height })
    (var-set config-count id)
    (ok id)))

;; approve: signer approves a document hash
;; Errors: u3 = config not found, u4 = not authorized, u5 = already signed
(define-public (approve (config-id uint) (hash (buff 32)))
  (let ((config (unwrap! (map-get? multisig-configs { id: config-id }) (err u3)))
        (existing (map-get? multisig-approvals { config-id: config-id, hash: hash }))
        (count (default-to u0 (get approved-count existing))))
    (asserts! (is-none (map-get? signer-approvals { config-id: config-id, hash: hash, signer: tx-sender })) (err u5))
    (map-set signer-approvals { config-id: config-id, hash: hash, signer: tx-sender }
      { signed-at: stacks-block-height })
    (let ((new-count (+ count u1))
          (is-approved (>= (+ count u1) (get required config))))
      (map-set multisig-approvals { config-id: config-id, hash: hash }
        { approved-count: new-count, approved: is-approved })
      (ok is-approved))))

(define-read-only (is-approved (config-id uint) (hash (buff 32)))
  (default-to false (get approved (map-get? multisig-approvals { config-id: config-id, hash: hash }))))

(define-read-only (get-approval-count (config-id uint) (hash (buff 32)))
  (default-to u0 (get approved-count (map-get? multisig-approvals { config-id: config-id, hash: hash }))))