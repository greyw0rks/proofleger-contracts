# ProofLedger Achievement NFTs

## Contract

`SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.achievements`

## Achievement Types

| Type | Earned By |
|---|---|
| `first-anchor` | Anchoring first document |
| `power-user` | Anchoring 10 documents |
| `century` | Anchoring 100 documents |
| `attester` | Attesting 5 documents |
| `verifier` | Running 25 verifications |
| `issuer` | Whitelist approval |

## Mint (Owner Only)

```clarity
(contract-call? .achievements mint
  SP_HOLDER_ADDRESS
  "first-anchor"
  0x<document-hash>)
;; Returns: (ok token-id)
```

## Check Achievement

```clarity
(contract-call? .achievements has-achievement SP_ADDRESS "century")
;; Returns: bool
```

## Soulbound

Transfer function returns `(err u403)` always — NFTs are permanently bound to the earning wallet.