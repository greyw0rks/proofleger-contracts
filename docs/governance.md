# ProofLedger Governance

The `governance.clar` contract enables community-driven protocol upgrades.

## Submit a Proposal

```clarity
(contract-call? .governance propose
  "Reduce verification fee to 0.0005 STX"
  "Current fee of 0.001 STX is too high for mobile users"
  "update-fee u500")
;; Returns: (ok proposal-id)
```

## Cast a Vote

```clarity
(contract-call? .governance vote u1 true)   ;; vote for
(contract-call? .governance vote u1 false)  ;; vote against
```

## Read Proposal

```clarity
(contract-call? .governance get-proposal u1)
;; Returns: { proposer, title, votes-for, votes-against, end-block, passed }
```

## Check Quorum

```clarity
(contract-call? .governance has-quorum u1)
;; Returns: bool (true if votes >= quorum threshold)
```

## Voting Period

Default: ~1440 blocks (~10 days on Stacks)