;; proof-of-attendance.clar
;; ProofLedger Proof of Attendance
;; Issue attendance credentials for events, conferences, and workshops

(define-map events
  { event-id: (string-ascii 50) }
  { organizer: principal, title: (string-ascii 100),
    location: (string-ascii 100), event-block: uint,
    created-at: uint, max-attendees: uint,
    attendee-count: uint, active: bool })

(define-map attendances
  { event-id: (string-ascii 50), attendee: principal }
  { check-in-block: uint, proof-hash: (buff 32) })

;; create-event: organizer registers an event
;; Errors: u1 = event ID already exists
(define-public (create-event (event-id (string-ascii 50)) (title (string-ascii 100))
                               (location (string-ascii 100)) (max-attendees uint))
  (begin
    (asserts! (is-none (map-get? events { event-id: event-id })) (err u1))
    (map-set events { event-id: event-id }
      { organizer: tx-sender, title: title, location: location,
        event-block: stacks-block-height, created-at: stacks-block-height,
        max-attendees: max-attendees, attendee-count: u0, active: true })
    (ok true)))

;; check-in: attendee checks in with a proof hash
;; Errors: u2 = event not found, u3 = event closed, u4 = already checked in, u5 = max capacity
(define-public (check-in (event-id (string-ascii 50)) (proof-hash (buff 32)))
  (let ((event (unwrap! (map-get? events { event-id: event-id }) (err u2))))
    (asserts! (get active event) (err u3))
    (asserts! (is-none (map-get? attendances { event-id: event-id, attendee: tx-sender })) (err u4))
    (asserts! (< (get attendee-count event) (get max-attendees event)) (err u5))
    (map-set attendances { event-id: event-id, attendee: tx-sender }
      { check-in-block: stacks-block-height, proof-hash: proof-hash })
    (map-set events { event-id: event-id }
      (merge event { attendee-count: (+ (get attendee-count event) u1) }))
    (ok true)))

(define-read-only (get-event (event-id (string-ascii 50)))
  (map-get? events { event-id: event-id }))

(define-read-only (get-attendance (event-id (string-ascii 50)) (attendee principal))
  (map-get? attendances { event-id: event-id, attendee: attendee }))

(define-read-only (attended (event-id (string-ascii 50)) (attendee principal))
  (is-some (map-get? attendances { event-id: event-id, attendee: attendee })))