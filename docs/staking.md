# ProofLedger Staking

The `staking.clar` contract lets STX holders lock tokens to earn
governance weight in protocol decisions.

## Stake

```clarity
;; Stake 10 STX — returns weight units
(contract-call? .staking stake u10000000)
;; Returns: (ok u10)   ;; 10 weight for 10 STX
```

## Check Weight

```clarity
(contract-call? .staking get-weight SP_ADDRESS)
;; Returns: uint — current governance weight
```

## Unstake (after lock period)

```clarity
;; Lock period is ~10 days (1440 blocks)
(contract-call? .staking unstake)
;; Returns: (ok amount-ustx) on success
;; Returns: (err u4) if still within lock period
```

## Parameters

| Parameter | Default | Notes |
|---|---|---|
| `min-stake` | 1,000,000 µSTX | 1 STX minimum |
| `lock-period` | 1,440 blocks | ~10 days |
| Weight formula | `amount / 1,000,000` | 1 weight per STX |