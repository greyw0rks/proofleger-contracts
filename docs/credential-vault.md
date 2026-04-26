# ProofLedger Credential Vault

The `credential-vault.clar` contract stores encrypted credential
references (IPFS CIDs, Arweave IDs) and lets owners selectively
share access with verifiers.

## Store a Credential

```clarity
(contract-call? .credential-vault store
  "ipfs://QmXyz..."
  "diploma")
;; Returns: (ok vault-id)
```

The `cipher-ref` field holds a pointer to the encrypted payload
stored off-chain. The private key never touches the chain.

## Grant Access

```clarity
;; Grant permanent access (expires-at = 0)
(contract-call? .credential-vault grant-access u1 SP_VERIFIER u0)

;; Grant time-limited access (expires at block 200000)
(contract-call? .credential-vault grant-access u1 SP_VERIFIER u200000)
```

## Check Access

```clarity
(contract-call? .credential-vault has-access u1 SP_VERIFIER)
;; Returns: bool
```

## Revoke Access

```clarity
(contract-call? .credential-vault revoke-access u1 SP_VERIFIER)
```