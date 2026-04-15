# ProofLedger Skill Tree

The `skill-tree.clar` contract enables on-chain skill tracking with proof-backed endorsements.

## Add a Skill

```clarity
(contract-call? .skill-tree add-skill
  "Clarity Smart Contracts"
  0x<proof-hash>)  ;; supporting credential
```

## Endorse Someone Skill

```clarity
(contract-call? .skill-tree endorse-skill
  SP_DEVELOPER_ADDRESS
  "Clarity Smart Contracts")
```

## Read Skills

```clarity
(contract-call? .skill-tree get-skill SP_ADDRESS "Solidity")
;; Returns: { level, first-proof, endorsements, last-updated }
```

## Use Cases
- Developer skill profiles
- Freelancer portfolio verification
- DAO contributor capability tracking