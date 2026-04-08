# ProofLedger npm Packages

| Package | Version | Description |
|---|---|---|
| `proofleger-sdk` | latest | JS SDK for document anchoring and verification |
| `proofleger-contracts` | latest | Clarity contract source and addresses |
| `proofleger` | latest | Full ProofLedger application |
| `proofleger-mainnet-tests` | latest | Testing utilities with Clarinet |
| `@greyw0rks/proofleger` | latest | Scoped ProofLedger package |

## Install All

```bash
npm install proofleger-sdk proofleger-contracts
```

## Usage

```javascript
const { verifyDocument } = require("proofleger-sdk");
const { CONTRACTS } = require("proofleger-contracts");

console.log(CONTRACTS.core);
// SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.proofleger3
```