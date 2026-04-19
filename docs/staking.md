# ProofLedger Staking

The `staking.clar` contract lets credential holders stake STX to earn yield and boost reputation.

## Stake STX

```clarity
(contract-call? .staking stake u1000000)    ;; stake 1 STX
```

## Unstake

```clarity
(contract-call? .staking unstake)
;; Returns: (ok amount-returned)
```

## Check Your Stake

```clarity
(contract-call? .staking get-stake tx-sender)
;; Returns: { amount, staked-at, last-claim, total-claimed }
```

## Protocol Stats

```clarity
(contract-call? .staking get-total-staked)
```