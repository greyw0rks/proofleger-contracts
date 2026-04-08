# ProofLedger Governance

## Creating a Proposal

```clarity
(contract-call? .governance create-proposal
  "Add medical credential support"
  "We should support FHIR-based medical credentials")
;; Returns: (ok u1) — proposal ID
```

## Voting

```clarity
;; Vote yes
(contract-call? .governance vote u1 true)
;; Vote no
(contract-call? .governance vote u1 false)
```

## Rules
- One vote per wallet per proposal
- Votes are permanent and cannot be changed
- Any wallet can create a proposal
- Proposals start active and remain open indefinitely

## Reading Results

```clarity
(contract-call? .governance get-proposal u1)
;; Returns: { creator, title, yes-votes, no-votes, active }