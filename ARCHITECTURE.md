# ProofLedger Contract Architecture

Three contracts work together to form a complete credential layer on Bitcoin.

## Flow

1. User anchors document hash via proofleger3
2. Third party attests to the hash via credentials
3. User mints soulbound NFT via achievements

## Contract Dependencies

proofleger3 is the source of truth.
credentials reads document hashes from proofleger3.
achievements mints tokens tied to anchored hashes.

## Data Model

proofleger3
  documents: hash -> { owner, block, title, type }
  wallet-docs: { owner, index } -> hash
  wallet-count: owner -> count

credentials
  attestations: { hash, issuer } -> { type, block }
  attestation-count: hash -> count
  attestation-index: { hash, index } -> issuer

achievements
  token-metadata: token-id -> { hash, type, title, block, owner }
  hash-to-token: { hash, owner } -> token-id
  owner-tokens: { owner, index } -> token-id
  owner-token-count: owner -> count
