# SDK Integration Guide

## Packages

```bash
npm install proofleger-sdk        # JS/TS SDK
npm install proofleger-contracts  # Contract source + addresses
npm install proofleger-mainnet-tests  # Test utilities
```

## Verify a Document

```javascript
const { verifyDocument } = require("proofleger-sdk");
const proof = await verifyDocument("a1b2c3...");
if (proof) console.log("Anchored at block:", proof.blockHeight);
```

## Get Contract Source

```javascript
const { getContract, CONTRACTS } = require("proofleger-contracts");
console.log(CONTRACTS.core); // SP1SY1...proofleger3
const source = getContract("proofleger3");
```

## Calculate Reputation

```javascript
const { calculateReputation } = require("proofleger-sdk");
const { score, tier } = calculateReputation([
  { docType: "diploma", attestations: 2, hasNFT: true }
]);
console.log(`${tier} — ${score} pts`);
```