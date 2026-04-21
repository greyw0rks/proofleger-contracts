;; messaging.clar
;; ProofLedger On-Chain Messaging
;; Store hashes of encrypted wallet-to-wallet messages on-chain

(define-map messages
  { id: uint }
  { sender: principal, recipient: principal,
    content-hash: (buff 32), sent-at: uint, read: bool })

(define-map inbox-count
  { recipient: principal }
  { count: uint, unread: uint })

(define-data-var message-count uint u0)

;; send-message: record an encrypted message hash
(define-public (send-message (recipient principal) (content-hash (buff 32)))
  (begin
    (asserts! (not (is-eq tx-sender recipient)) (err u1))
    (let ((id (+ (var-get message-count) u1))
          (ic (default-to { count:u0, unread:u0 }
                (map-get? inbox-count { recipient: recipient }))))
      (map-set messages { id: id }
        { sender: tx-sender, recipient: recipient,
          content-hash: content-hash, sent-at: stacks-block-height, read: false })
      (map-set inbox-count { recipient: recipient }
        { count: (+ (get count ic) u1), unread: (+ (get unread ic) u1) })
      (var-set message-count id)
      (ok id))))

;; mark-read: recipient marks a message as read
;; Errors: u2 = not found, u3 = not recipient
(define-public (mark-read (message-id uint))
  (let ((msg (unwrap! (map-get? messages { id: message-id }) (err u2))))
    (asserts! (is-eq tx-sender (get recipient msg)) (err u3))
    (map-set messages { id: message-id } (merge msg { read: true }))
    (let ((ic (default-to { count:u0, unread:u0 }
                (map-get? inbox-count { recipient: tx-sender }))))
      (map-set inbox-count { recipient: tx-sender }
        (merge ic { unread: (if (> (get unread ic) u0) (- (get unread ic) u1) u0) })))
    (ok true)))

(define-read-only (get-message (id uint))
  (map-get? messages { id: id }))

(define-read-only (get-inbox-count (recipient principal))
  (map-get? inbox-count { recipient: recipient }))