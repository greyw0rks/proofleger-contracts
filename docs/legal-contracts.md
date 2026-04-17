# ProofLedger Legal Contracts

The `legal-contracts.clar` contract enables bilateral contract anchoring with on-chain signatures.

## Propose a Contract

Party A proposes (and auto-signs):

```clarity
(contract-call? .legal-contracts propose-contract
  0x<contract-document-hash>
  SP_PARTY_B_ADDRESS
  "service-agreement"
  "Software development contract Q2 2026")
```

## Countersign

Party B countersigns:

```clarity
(contract-call? .legal-contracts countersign 0x<hash>)
```

## Check Execution Status

```clarity
(contract-call? .legal-contracts is-executed 0x<hash>)
;; Returns: true only when both parties have signed
```

## Contract Types

`service-agreement`, `nda`, `lease`, `sale`, `employment`, `partnership`, `loan`, `other`