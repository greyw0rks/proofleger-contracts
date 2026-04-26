# ProofLedger Governance

The `governance.clar` contract enables stake-weighted protocol governance.
Any principal may submit proposals; only stakers carry voting weight.

## Submit a Proposal

```clarity
(contract-call? .governance propose
  "Enable issuer whitelist"
  "Require verified issuer status to anchor credentials")
;; Returns: (ok proposal-id)
```

## Cast a Vote

Weight comes from `staking.clar`. Retrieve it then vote:

```clarity
(let ((weight (contract-call? .staking get-weight tx-sender)))
  (contract-call? .governance vote u1 weight true))
;; Returns: (ok true)
```

## Proposal Lifecycle

```
propose → voting window (288 blocks ~2 days) → finalize
```

A proposal passes if `votes-for / total >= 60%`.

## Read Proposal State

```clarity
(contract-call? .governance get-proposal u1)
;; { title, votes-for, votes-against, closes-at, passed, executed }
```