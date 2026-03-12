# ProofLedger Integration Guide

How to integrate ProofLedger contracts into your own Stacks dApp.

---

## Prerequisites

- `@stacks/connect` v8+
- `@stacks/transactions` v6+
- Hiro Wallet or any Stacks-compatible wallet

```bash
npm install @stacks/connect @stacks/transactions
```

---

## 1. Anchor a Document

Compute the SHA-256 hash client-side and submit it to the contract.

```javascript
import { makeContractCall, bufferCV, stringAsciiCV } from "@stacks/transactions";

const CONTRACT = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";

async function anchorDocument(hashHex, title, docType) {
  const hashBuffer = Buffer.from(hashHex, "hex");

  const txOptions = {
    contractAddress: CONTRACT,
    contractName: "proofleger3",
    functionName: "anchor-document",
    functionArgs: [
      bufferCV(hashBuffer),
      stringAsciiCV(title),
      stringAsciiCV(docType),
    ],
    network: "mainnet",
    postConditions: [],
  };

  // Submit via @stacks/connect
  await openContractCall(txOptions);
}
```

---

## 2. Verify a Document

Use a read-only call — no wallet required.

```javascript
import { fetchCallReadOnlyFunction, bufferCV, standardPrincipalCV } from "@stacks/transactions";

async function verifyDocument(hashHex) {
  const result = await fetchCallReadOnlyFunction({
    contractAddress: CONTRACT,
    contractName: "proofleger3",
    functionName: "verify-document",
    functionArgs: [bufferCV(Buffer.from(hashHex, "hex"))],
    senderAddress: CONTRACT,
    network: "mainnet",
  });

  if (result.type === "some") {
    return result.value; // { owner, block-height, title, doc-type }
  }
  return null; // not found
}
```

---

## 3. Compute SHA-256 in the Browser

Never upload files. Hash client-side using the Web Crypto API.

```javascript
async function hashFile(file) {
  const buffer = await file.arrayBuffer();
  const hashBuffer = await crypto.subtle.digest("SHA-256", buffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}
```

> Note: `crypto.subtle` requires HTTPS. Use a self-signed cert or Vercel for local testing.

---

## 4. Issue a Credential

```javascript
async function issueCredential(recipientAddress, hashHex, credType, issuerName) {
  await openContractCall({
    contractAddress: CONTRACT,
    contractName: "credentials",
    functionName: "issue-credential",
    functionArgs: [
      standardPrincipalCV(recipientAddress),
      bufferCV(Buffer.from(hashHex, "hex")),
      stringAsciiCV(credType),
      stringAsciiCV(issuerName),
    ],
    network: "mainnet",
    postConditions: [],
  });
}
```

---

## 5. Read Reputation Score

Reputation is computed off-chain from on-chain data:

```javascript
const SCORES = { diploma: 50, research: 40, certificate: 30, art: 20, contribution: 20, award: 10, other: 10 };

async function getReputation(address) {
  const count = await fetchDocumentCount(address);
  // Fetch each document and sum scores by type
  // Add +10 per attestation received, +25 per NFT minted
  return totalScore;
}
```

---

## Contract Addresses

| Contract | Mainnet |
|---|---|
| proofleger3 | `SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.proofleger3` |
| credentials | `SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.credentials` |
| achievements | `SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK.achievements` |

Explorer: [explorer.hiro.so](https://explorer.hiro.so)
