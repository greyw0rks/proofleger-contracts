# Security Model

## Immutability
Once a document hash is anchored via proofleger3, it cannot be modified or deleted.
The store function rejects any attempt to re-anchor an existing hash.

## No Admin Keys
These contracts have no owner, no admin functions, and no upgrade mechanism.
No single party can alter, pause, or destroy stored data.

## Trust Model
Documents are never uploaded. Only SHA-256 hashes touch the blockchain.
The hash proves existence and integrity without revealing content.

## Attestation Trust
Attestations are only as trustworthy as the issuing principal.
Anyone can attest to any hash. Consumers should verify issuer identity off-chain.

## Soulbound Enforcement
The achievements contract has no transfer function.
nft-transfer? is never called, making tokens permanently bound to the minting wallet.

## Known Limitations
No on-chain document content verification.
No revocation mechanism for attestations.
No token burning mechanism for achievements.
