# ProofLedger Timelock Controller

The `timelock.clar` contract enforces a mandatory delay (~24 hours) before
sensitive protocol actions can be executed.

## Queue an Action

```clarity
(contract-call? .timelock queue-action
  "Upgrade proofleger contract to v4")
;; Returns: (ok { action-id: u1, eta: u<block> })
```

## Check Executability

```clarity
(contract-call? .timelock is-executable u1)
;; Returns: bool — true after delay, false before or after grace window
```

## Execute

```clarity
(contract-call? .timelock execute-action u1)
;; Succeeds only within the [eta, eta + grace] window
```

## Cancel

```clarity
(contract-call? .timelock cancel-action u1)
;; Owner can cancel any non-executed action
```

## Timing Parameters

| Parameter | Default | Meaning |
|---|---|---|
| `delay-blocks` | 144 | ~24h before execution is allowed |
| `grace-blocks` | 1008 | ~7d execution window after delay passes |