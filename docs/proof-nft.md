# ProofLedger Proof Certificate NFTs

The `proof-nft.clar` contract issues SIP-009 NFTs when a document is anchored,
creating a tradeable on-chain certificate of authenticity.

## Mint a Certificate

```clarity
;; Called automatically by the anchor contract on proof submission
(contract-call? .proof-nft mint
  SP_RECIPIENT
  0x<32-byte-hash>
  "MIT Computer Science Diploma 2026"
  "diploma")
;; Returns: (ok token-id)
```

## Check Ownership

```clarity
(contract-call? .proof-nft get-owner u1)
;; Returns: (ok (some SP_ADDRESS))
```

## Get Certificate Metadata

```clarity
(contract-call? .proof-nft get-token-metadata u1)
;; Returns: (some { owner, hash, title, doc-type, minted-at, network })
```

## Token URI

Each token resolves to:
`https://verify.proofleger.vercel.app/cert/<token-id>`

## SIP-009 Compliance

The contract implements all required SIP-009 read-only and public functions:
`get-last-token-id`, `get-token-uri`, `get-owner`, and `transfer`.