# ProofLedger Error Codes

All Clarity error codes used across ProofLedger contracts.

---

## proofleger3.clar

| Code | Constant | Description |
|---|---|---|
| u100 | ERR_ALREADY_EXISTS | Document hash already anchored on-chain |
| u101 | ERR_INVALID_HASH | Hash buffer is empty or malformed |
| u102 | ERR_NOT_FOUND | Hash not found in documents map |
| u103 | ERR_SELF_ATTEST | Cannot attest your own document |
| u104 | ERR_ALREADY_ATTESTED | Caller has already attested this document |
| u105 | ERR_INVALID_TITLE | Title is empty or exceeds 100 characters |
| u106 | ERR_INVALID_TYPE | Document type exceeds 50 characters |

## credentials.clar

| Code | Constant | Description |
|---|---|---|
| u100 | ERR_ALREADY_EXISTS | Credential already issued for this recipient + hash |
| u101 | ERR_DUPLICATE | Duplicate issuance attempt |
| u403 | ERR_NOT_AUTHORIZED | Caller is not the original issuer |
| u404 | ERR_NOT_FOUND | Credential does not exist |
| u410 | ERR_REVOKED | Credential has already been revoked |

## achievements.clar

| Code | Constant | Description |
|---|---|---|
| u100 | ERR_ALREADY_EXISTS | Achievement already minted for this wallet + hash |
| u101 | ERR_NOT_FOUND | Token ID does not exist |
| u102 | ERR_DUPLICATE | Duplicate mint attempt |
| u500 | ERR_SOULBOUND | Transfer blocked — achievements are soulbound |
| u403 | ERR_NOT_AUTHORIZED | Only contract owner can mint |

---

## Handling Errors in the Frontend

```javascript
// wallet.js pattern for reading error codes
if (result.value?.type === "err") {
  const code = result.value.value.value;
  switch (code) {
    case 100n: return "This document has already been anchored.";
    case 103n: return "You cannot attest your own document.";
    case 104n: return "You have already attested this document.";
    default:   return `Contract error: u${code}`;
  }
}
```
