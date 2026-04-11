# ProofLedger Achievements v2

Enhanced soulbound NFTs with external metadata URI and category support.

## Mint with Metadata

```clarity
(contract-call? .achievements-v2 mint
  0x<sha256-hash>
  "diploma"
  "Bachelor of Science"
  "ipfs://QmYourMetadataCID"
  "education")
```

## Metadata URI

The `metadata-uri` field supports:
- IPFS: `ipfs://Qm...`
- HTTPS: `https://...`
- Empty string for on-chain only

## Categories

Common categories:
- `education` — degrees, certificates
- `professional` — work achievements
- `community` — DAO contributions
- `awards` — competitions, hackathons

## Read NFT Data

```clarity
(contract-call? .achievements-v2 get-token-metadata u1)
;; Returns full metadata including URI and category
```