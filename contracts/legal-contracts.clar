;; legal-contracts.clar
;; ProofLedger Legal Contract Registry
;; Anchor bilateral contracts with both parties signing on-chain

(define-map legal-contracts
  { hash: (buff 32) }
  { party-a: principal, party-b: principal,
    contract-type: (string-ascii 50), description: (string-ascii 200),
    created-at: uint, signed-a: bool, signed-b: bool, executed: bool })

(define-data-var total-contracts uint u0)

;; propose-contract: party A proposes a contract with party B
;; Errors: u1 = hash already exists
(define-public (propose-contract (hash (buff 32)) (party-b principal)
                                   (contract-type (string-ascii 50))
                                   (description (string-ascii 200)))
  (begin
    (asserts! (is-none (map-get? legal-contracts { hash: hash })) (err u1))
    (asserts! (not (is-eq tx-sender party-b)) (err u2))
    (map-set legal-contracts { hash: hash }
      { party-a: tx-sender, party-b: party-b,
        contract-type: contract-type, description: description,
        created-at: stacks-block-height,
        signed-a: true, signed-b: false, executed: false })
    (var-set total-contracts (+ (var-get total-contracts) u1))
    (ok true)))

;; countersign: party B signs the proposed contract
;; Errors: u3 = not found, u4 = not party B, u5 = already signed
(define-public (countersign (hash (buff 32)))
  (let ((contract (unwrap! (map-get? legal-contracts { hash: hash }) (err u3))))
    (asserts! (is-eq tx-sender (get party-b contract)) (err u4))
    (asserts! (not (get signed-b contract)) (err u5))
    (map-set legal-contracts { hash: hash }
      (merge contract { signed-b: true, executed: true }))
    (ok true)))

(define-read-only (get-contract (hash (buff 32)))
  (map-get? legal-contracts { hash: hash }))

(define-read-only (is-executed (hash (buff 32)))
  (default-to false (get executed (map-get? legal-contracts { hash: hash }))))