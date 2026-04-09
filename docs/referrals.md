# ProofLedger Referral System

Track who introduced new users to the ProofLedger ecosystem.

## Register a Referral

```clarity
;; Called by the new user, passing the referrer address
(contract-call? .referrals register-referral SP_REFERRER_ADDRESS)
```

## Check Referrals

```clarity
;; How many users did this wallet refer?
(contract-call? .referrals get-referral-count SP_ADDRESS)

;; Who referred this wallet?
(contract-call? .referrals get-referral tx-sender)
```

## Rules

- Each wallet can only register one referrer
- Cannot refer yourself
- Referrals are permanent