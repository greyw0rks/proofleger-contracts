# Changelog

## v1.0.0 - March 2026

### Deployed to Mainnet
- proofleger3 core anchoring contract
- credentials attestation contract
- achievements soulbound NFT contract

### Features
- SHA-256 document anchoring to Bitcoin via Stacks
- Third party on-chain attestations
- Soulbound achievement NFTs tied to documents
- Public wallet profiles at proofleger.vercel.app/profile/[wallet]
- Decentralized CV at proofleger.vercel.app/cv/[wallet]
- On-chain reputation scoring system
- Protocol analytics dashboard

### Contract Addresses
- SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.proofleger3
- SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.credentials
- SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.achievements

## [1.1.0] - 2026-03-12

### Added
- Unit test suite for all three contracts (proofleger3, credentials, achievements)
- GitHub Actions CI pipeline with Clarinet test runner
- Deployment helper script with testnet/mainnet safety gate
- Contract reference documentation
- Error codes reference documentation
- Integration guide for third-party developers

### Changed
- Improved deploy.sh with pre-deploy test gate
- CI now runs on both push to main and pull requests

### Security
- Added CI security scan for hardcoded secrets in contracts
- Documented all ERR_ codes and their conditions
