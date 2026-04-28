;; sdk-registry.clar
;; ProofLedger SDK Registry
;; Track registered SDK integrations and their usage stats

(define-map integrations
  { app-id: uint }
  { name:         (string-ascii 80),
    owner:        principal,
    api-key-hash: (buff 32),   ;; SHA-256 of API key — never stored plain
    registered-at: uint,
    active:        bool,
    call-count:   uint,
    plan:         (string-ascii 10) })  ;; free | pro | enterprise

(define-map owner-apps
  { owner: principal, index: uint }
  { app-id: uint })

(define-map owner-app-counts
  { owner: principal }
  { count: uint })

(define-data-var registry-admin principal tx-sender)
(define-data-var app-count      uint u0)

;; register: developer registers a new SDK integration
(define-public (register (name          (string-ascii 80))
                           (api-key-hash  (buff 32))
                           (plan          (string-ascii 10)))
  (let ((id (+ (var-get app-count) u1)))
    (map-set integrations { app-id: id }
      { name:          name,
        owner:         tx-sender,
        api-key-hash:  api-key-hash,
        registered-at: stacks-block-height,
        active:        true,
        call-count:    u0,
        plan:          plan })
    (let ((oc (default-to u0 (get count (map-get? owner-app-counts { owner: tx-sender })))))
      (map-set owner-apps { owner: tx-sender, index: oc } { app-id: id })
      (map-set owner-app-counts { owner: tx-sender } { count: (+ oc u1) }))
    (var-set app-count id)
    (ok id)))

;; record-call: increment API call counter for an integration
;; Errors: u1 = not found, u2 = not owner
(define-public (record-call (app-id uint))
  (let ((app (unwrap! (map-get? integrations { app-id: app-id }) (err u1))))
    (asserts! (get active app) (err u3))
    (map-set integrations { app-id: app-id }
      (merge app { call-count: (+ (get call-count app) u1) }))
    (ok (+ (get call-count app) u1))))

;; deactivate: admin or owner deactivates an integration
(define-public (deactivate (app-id uint))
  (let ((app (unwrap! (map-get? integrations { app-id: app-id }) (err u1))))
    (asserts! (or (is-eq tx-sender (var-get registry-admin))
                  (is-eq tx-sender (get owner app))) (err u2))
    (map-set integrations { app-id: app-id }
      (merge app { active: false }))
    (ok true)))

(define-read-only (get-integration (app-id uint))
  (map-get? integrations { app-id: app-id }))

(define-read-only (get-owner-count (owner principal))
  (default-to u0 (get count (map-get? owner-app-counts { owner: owner }))))

(define-read-only (get-app-count) (var-get app-count))