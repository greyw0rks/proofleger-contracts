# ProofLedger Leaderboard

The `leaderboard.clar` contract maintains an on-chain ranking of top contributors.

## Update Rankings

```clarity
;; Update rank #1 with score 1500
(contract-call? .leaderboard update-rank SP_ADDRESS u1 u1500)
```

## Read Rankings

```clarity
;; Get the #1 ranked contributor
(contract-call? .leaderboard get-rank u1)
;; Returns: { address, score, updated-at }

;; Get a specific user rank
(contract-call? .leaderboard get-user-rank SP_ADDRESS)
```

## How Rankings Work

Rankings are updated off-chain (by the ProofLedger bot) based on:
- Total documents anchored
- Attestations received
- NFTs minted
- Endorsements received

The computed scores are then written on-chain for public verification.