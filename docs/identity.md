# ProofLedger Identity

The `identity.clar` contract enables self-sovereign identity on Stacks.

## Register Identity

```clarity
(contract-call? .identity register-identity
  "did:stacks:SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK"
  "Alice Builder")
```

## Add Claims

```clarity
(contract-call? .identity add-claim
  "education"
  "MIT Computer Science 2024"
  0x<proof-hash>)
```

## Read Identity

```clarity
(contract-call? .identity get-identity SP_ADDRESS)
;; Returns: { did, display-name, created-at, updated-at }

(contract-call? .identity get-claim SP_ADDRESS "education")
;; Returns: { value, proof-hash, issued-at, issuer }
```

## DID Format

Recommended DID format for Stacks:
`did:stacks:{SP_ADDRESS}`