# ProofLedger Contract Reference

Complete function reference for all three deployed Clarity contracts.

---

## proofleger3.clar — Core Anchoring

**Mainnet:** `SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.proofleger3`

### Public Functions

#### `anchor-document`
Stores a SHA-256 hash permanently on-chain.

```clarity
(anchor-document
  (hash (buff 32))
  (title (string-ascii 100))
  (doc-type (string-ascii 50)))
→ (response bool uint)
```

| Error | Code | Reason |
|---|---|---|
| ERR_ALREADY_EXISTS | 100 | Hash already anchored |
| ERR_INVALID_HASH | 101 | Hash buffer is empty |

#### `attest-document`
Adds an attestation to an existing anchored document.

```clarity
(attest-document (hash (buff 32)))
→ (response bool uint)
```

| Error | Code | Reason |
|---|---|---|
| ERR_NOT_FOUND | 102 | Hash not anchored |
| ERR_SELF_ATTEST | 103 | Cannot attest own document |
| ERR_ALREADY_ATTESTED | 104 | Already attested this document |

### Read-Only Functions

#### `verify-document`
Returns document metadata or none if not found.

```clarity
(verify-document (hash (buff 32)))
→ (optional { owner: principal, block-height: uint, title: string-ascii, doc-type: string-ascii })
```

#### `get-document-count`
Returns total documents anchored by a wallet.

```clarity
(get-document-count (owner principal))
→ uint
```

#### `get-attestation-count`
Returns total attestations for a document.

```clarity
(get-attestation-count (hash (buff 32)))
→ uint
```

---

## credentials.clar — Credential Issuance

**Mainnet:** `SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.credentials`

### Public Functions

#### `issue-credential`
Issues a verifiable credential to a recipient.

```clarity
(issue-credential
  (recipient principal)
  (hash (buff 32))
  (cred-type (string-ascii 50))
  (issuer-name (string-ascii 100)))
→ (response bool uint)
```

#### `revoke-credential`
Revokes a credential. Only the original issuer can revoke.

```clarity
(revoke-credential
  (recipient principal)
  (hash (buff 32)))
→ (response bool uint)
```

| Error | Code | Reason |
|---|---|---|
| ERR_NOT_AUTHORIZED | 403 | Caller is not the issuer |
| ERR_NOT_FOUND | 404 | Credential does not exist |

### Read-Only Functions

#### `get-credential`
Returns credential data for a recipient and hash.

```clarity
(get-credential (recipient principal) (hash (buff 32)))
→ (optional { issuer: principal, issuer-name: string-ascii, cred-type: string-ascii, block-height: uint, revoked: bool })
```

---

## achievements.clar — Soulbound NFTs

**Mainnet:** `SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.achievements`

### Public Functions

#### `mint-achievement`
Mints a soulbound (non-transferable) NFT for a verified credential.

```clarity
(mint-achievement
  (recipient principal)
  (hash (buff 32))
  (achievement-type (string-ascii 50))
  (title (string-ascii 100)))
→ (response uint uint)
```

Returns the new token ID on success.

#### `transfer`
Always fails. Achievements are soulbound and non-transferable.

```clarity
(transfer (token-id uint) (sender principal) (recipient principal))
→ (response bool uint)  ;; always err u500
```

### Read-Only Functions

#### `get-achievement`
Returns metadata for a given token ID.

```clarity
(get-achievement (token-id uint))
→ (optional { owner: principal, hash: buff, achievement-type: string-ascii, title: string-ascii, block-height: uint })
```

#### `get-token-owner`
Returns the owner of a token ID (SIP-009 compliant).

```clarity
(get-owner (token-id uint))
→ (response (optional principal) uint)
```
