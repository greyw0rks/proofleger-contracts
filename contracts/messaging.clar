;; messaging.clar
;; ProofLedger On-Chain Messaging
;; Anchor public messages permanently to Bitcoin via Stacks

(define-map messages
  { sender: principal, index: uint }
  { content: (string-ascii 500), timestamp: uint, reference-hash: (optional (buff 32)) })

(define-map message-count
  { sender: principal }
  { count: uint })

;; send-message: anchor a message on-chain
;; Optionally reference a document hash
(define-public (send-message (content (string-ascii 500)) (reference-hash (optional (buff 32))))
  (let ((count (default-to u0 (get count (map-get? message-count { sender: tx-sender })))))
    (asserts! (> (len content) u0) (err u1))
    (map-set messages { sender: tx-sender, index: count }
      { content: content, timestamp: stacks-block-height, reference-hash: reference-hash })
    (map-set message-count { sender: tx-sender } { count: (+ count u1) })
    (ok count)))

(define-read-only (get-message (sender principal) (index uint))
  (map-get? messages { sender: sender, index: index }))

(define-read-only (get-message-count (sender principal))
  (default-to u0 (get count (map-get? message-count { sender: sender }))))