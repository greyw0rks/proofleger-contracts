# ProofLedger Badges

## Create a Badge Type

```clarity
(contract-call? .badges create-badge
  "hackathon-winner"
  "Hackathon Winner"
  "Awarded to hackathon first place finishers")
```

## Issue a Badge

```clarity
(contract-call? .badges issue-badge
  SP_RECIPIENT_ADDRESS
  "hackathon-winner")
```

## Check Badge Status

```clarity
(contract-call? .badges has-badge SP_RECIPIENT SP_ISSUER "hackathon-winner")
;; Returns: bool
```

## Rules

- Anyone can create a badge definition
- Anyone can issue any existing badge to any wallet
- One badge instance per issuer per recipient per badge-id
- All badges are permanent on-chain