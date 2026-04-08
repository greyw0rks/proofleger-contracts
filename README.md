# ProofLedger Contracts

Clarity smart contracts for the ProofLedger document anchoring protocol on Stacks/Bitcoin.

## Contracts

| Contract | Purpose |
|---|---|
| proofleger3 | Core document anchoring |
| credentials | Verifiable credential issuance |
| achievements | Soulbound NFTs |
| endorsements | Social endorsements |
| profiles | On-chain profile storage |
| revocations | Document revocation |
| reputation | Reputation score storage |
| collections | Document grouping |
| badges | Community badges |
| registry | Trusted issuer registry |
| governance | Proposals and voting |
| subscriptions | Wallet subscriptions |
| messaging | On-chain messages |
| timestamps | General timestamp anchoring |
| oracle | Trusted data feeds |

## Deploy

```bash
clarinet check
clarinet test
```

## npm

```bash
npm install proofleger-contracts
```

```javascript
const { CONTRACTS, getContract } = require("proofleger-contracts");
console.log(CONTRACTS.core);
```

## Live App

[proofleger.vercel.app](https://proofleger.vercel.app)