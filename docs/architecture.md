# ProofLedger Architecture

## Smart Contract Layer

### Core
- `proofleger3` — SHA-256 hash anchoring
- `credentials` — verifiable credential issuance
- `achievements` — soulbound NFTs

### Social Layer
- `endorsements` — social endorsements
- `profiles` — on-chain profiles
- `badges` — community badges
- `subscriptions` — wallet following
- `messaging` — on-chain messages

### Governance
- `governance` — proposals and voting
- `registry` — trusted issuer verification

### Utility
- `revocations` — document revocation
- `reputation` — score storage
- `collections` — document grouping
- `timestamps` — general anchoring
- `oracle` — trusted data feeds

## Frontend
- Next.js 16 + React
- Hiro Wallet (@stacks/connect v8)
- Celo/MiniPay (viem)

## Infrastructure
- Vercel (frontend)
- AWS EC2 + PM2 (bots)
- ProofLedger Verifier (SQLite indexer)