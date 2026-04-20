;; registry.clar
;; ProofLedger Contract Registry
;; Central registry for all ProofLedger contract addresses and metadata

(define-map contracts
  { name: (string-ascii 50) }
  { contract-principal: principal, version: (string-ascii 20),
    deployed-at: uint, active: bool, description: (string-ascii 200) })

(define-map contract-history
  { name: (string-ascii 50), version: (string-ascii 20) }
  { contract-principal: principal, deprecated-at: uint })

(define-data-var registry-admin principal tx-sender)
(define-data-var contract-count uint u0)

;; register-contract: admin registers a deployed contract
;; Errors: u401 = not admin
(define-public (register-contract (name (string-ascii 50))
                                    (contract-principal principal)
                                    (version (string-ascii 20))
                                    (description (string-ascii 200)))
  (begin
    (asserts! (is-eq tx-sender (var-get registry-admin)) (err u401))
    ;; Archive previous version if exists
    (match (map-get? contracts { name: name })
      existing (map-set contract-history { name: name, version: (get version existing) }
        { contract-principal: (get contract-principal existing),
          deprecated-at: stacks-block-height })
      true)
    (map-set contracts { name: name }
      { contract-principal: contract-principal, version: version,
        deployed-at: stacks-block-height, active: true, description: description })
    (var-set contract-count (+ (var-get contract-count) u1))
    (ok true)))

;; deprecate: mark a contract version as deprecated
(define-public (deprecate (name (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get registry-admin)) (err u401))
    (match (map-get? contracts { name: name })
      c (map-set contracts { name: name } (merge c { active: false }))
      true)
    (ok true)))

(define-read-only (get-contract (name (string-ascii 50)))
  (map-get? contracts { name: name }))

(define-read-only (get-active-principal (name (string-ascii 50)))
  (get contract-principal (map-get? contracts { name: name })))

(define-read-only (is-active (name (string-ascii 50)))
  (default-to false (get active (map-get? contracts { name: name }))))