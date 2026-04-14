# ProofLedger Proof Chains

The `proof-chain.clar` contract links related documents into verifiable evidence chains.

## Create a Chain

```clarity
(contract-call? .proof-chain create-chain "Contract Dispute Evidence")
;; Returns: (ok chain-id)
```

## Add Documents to Chain

```clarity
(contract-call? .proof-chain add-link
  u1               ;; chain ID
  0x<hash>         ;; document hash
  "Initial contract signed by both parties")
```

## Read Chain

```clarity
(contract-call? .proof-chain get-chain u1)
;; Returns: { creator, title, length, created-at }

(contract-call? .proof-chain get-link u1 u0)
;; Returns first link in chain
```

## Use Cases
- Legal evidence chains
- Audit trails with document proofs
- Research citation chains
- Supply chain document tracking