# ProofLedger Proof of Attendance

The `proof-of-attendance.clar` contract issues verifiable attendance credentials.

## Create an Event

```clarity
(contract-call? .proof-of-attendance create-event
  "STACKS-SUMMIT-2026"
  "Stacks Summit Lagos 2026"
  "Lagos, Nigeria"
  u500)   ;; max attendees
```

## Attendee Check-In

```clarity
(contract-call? .proof-of-attendance check-in
  "STACKS-SUMMIT-2026"
  0x<ticket-hash>)
```

## Verify Attendance

```clarity
(contract-call? .proof-of-attendance attended
  "STACKS-SUMMIT-2026"
  SP_ATTENDEE_ADDRESS)
;; Returns: bool
```

## Use Cases
- Conference attendance certificates
- Hackathon participation proofs
- Course completion verification
- Community event credentials