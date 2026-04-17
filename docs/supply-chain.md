# ProofLedger Supply Chain

The `supply-chain.clar` contract tracks documents through multi-step supply chain processes.

## Create a Shipment Trail

```clarity
(contract-call? .supply-chain create-shipment
  "SHIP-2026-001"
  "Lagos, Nigeria"
  "London, UK")
```

## Add Steps

Each party along the chain adds their document proof:

```clarity
(contract-call? .supply-chain add-step
  "SHIP-2026-001"
  "Customs inspection completed"
  0x<inspection-report-hash>)
```

## Complete Shipment

```clarity
;; Initiator only
(contract-call? .supply-chain complete-shipment "SHIP-2026-001")
```

## Read Trail

```clarity
(contract-call? .supply-chain get-shipment "SHIP-2026-001")
;; Returns: { initiator, origin, destination, step-count, completed }

(contract-call? .supply-chain get-step "SHIP-2026-001" u0)
;; Returns first step: { actor, action, doc-hash, completed-at }
```