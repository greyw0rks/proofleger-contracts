;; timelock.clar
;; ProofLedger Timelock Controller
;; Queue actions with a mandatory delay before execution

(define-map queued-actions
  { action-id: uint }
  { description: (string-ascii 200),
    proposer: principal,
    queued-at: uint,
    eta: uint,
    executed: bool,
    cancelled: bool })

(define-map queue-counts { proposer: principal } { count: uint })

(define-data-var timelock-owner principal tx-sender)
(define-data-var delay-blocks uint u144)   ;; ~24 hours at 10min/block
(define-data-var grace-blocks  uint u1008) ;; ~7 day execution window
(define-data-var total-queued  uint u0)

;; queue-action: submit an action with a mandatory delay
;; Errors: u401 = not owner
(define-public (queue-action (description (string-ascii 200)))
  (begin
    (asserts! (is-eq tx-sender (var-get timelock-owner)) (err u401))
    (let ((id  (+ (var-get total-queued) u1))
          (eta (+ stacks-block-height (var-get delay-blocks))))
      (map-set queued-actions { action-id: id }
        { description: description,
          proposer:     tx-sender,
          queued-at:    stacks-block-height,
          eta:          eta,
          executed:     false,
          cancelled:    false })
      (var-set total-queued id)
      (ok { action-id: id, eta: eta }))))

;; execute-action: run a queued action after the delay window
;; Errors: u402 = not found, u403 = too early, u404 = expired, u405 = already done
(define-public (execute-action (action-id uint))
  (let ((action (unwrap! (map-get? queued-actions { action-id: action-id }) (err u402))))
    (asserts! (is-eq tx-sender (var-get timelock-owner)) (err u401))
    (asserts! (not (get executed action))  (err u405))
    (asserts! (not (get cancelled action)) (err u405))
    (asserts! (>= stacks-block-height (get eta action)) (err u403))
    (asserts! (<  stacks-block-height (+ (get eta action) (var-get grace-blocks))) (err u404))
    (map-set queued-actions { action-id: action-id }
      (merge action { executed: true }))
    (ok true)))

;; cancel-action: owner cancels a pending action before execution
(define-public (cancel-action (action-id uint))
  (let ((action (unwrap! (map-get? queued-actions { action-id: action-id }) (err u402))))
    (asserts! (is-eq tx-sender (var-get timelock-owner)) (err u401))
    (asserts! (not (get executed action)) (err u405))
    (map-set queued-actions { action-id: action-id }
      (merge action { cancelled: true }))
    (ok true)))

(define-public (set-delay (new-delay uint))
  (begin
    (asserts! (is-eq tx-sender (var-get timelock-owner)) (err u401))
    (asserts! (>= new-delay u72) (err u406))  ;; minimum ~12 hours
    (var-set delay-blocks new-delay)
    (ok new-delay)))

(define-read-only (get-action (action-id uint))
  (map-get? queued-actions { action-id: action-id }))

(define-read-only (is-executable (action-id uint))
  (match (map-get? queued-actions { action-id: action-id })
    a (and
        (not (get executed a))
        (not (get cancelled a))
        (>= stacks-block-height (get eta a))
        (< stacks-block-height (+ (get eta a) (var-get grace-blocks))))
    false))

(define-read-only (get-delay) (var-get delay-blocks))
(define-read-only (get-total-queued) (var-get total-queued))