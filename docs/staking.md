# ProofLedger Staking

The `staking.clar` contract allows STX holders to signal commitment to the ecosystem.

## Stake

```clarity
(contract-call? .staking stake u100000)
;; Locks 0.1 STX for ~1 day (144 blocks)
```

## Unstake

```clarity
;; Only works after lock period expires
(contract-call? .staking unstake)
;; Returns the staked amount
```

## Check Stake

```clarity
(contract-call? .staking get-stake tx-sender)
;; Returns: { amount, staked-at, unlock-at }
```

## Lock Period

Staked STX is locked for **144 blocks (~1 day)**.
Early unstaking is rejected with `err u4`.