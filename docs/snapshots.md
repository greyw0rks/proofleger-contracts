# ProofLedger Snapshots

The `snapshots.clar` contract records periodic protocol metrics on-chain.

## Record a Snapshot

```clarity
(contract-call? .snapshots record-snapshot
  u1500   ;; total documents
  u320    ;; total wallets
  u4200   ;; total attestations
  u890)   ;; total NFTs
;; Returns: (ok epoch-number)
```

## Read Snapshots

```clarity
;; Get latest
(contract-call? .snapshots get-latest-snapshot)

;; Get specific epoch
(contract-call? .snapshots get-snapshot u5)

;; Total snapshots recorded
(contract-call? .snapshots get-snapshot-count)
```

## How It Works

The ProofLedger bot records snapshots daily after each run,
creating a permanent on-chain history of protocol growth.