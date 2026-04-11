# ProofLedger Notary

The `notary.clar` contract enables on-chain document notarization with witness signatures.

## Notarize a Document

```clarity
(contract-call? .notary notarize
  0x<sha256-hash>
  "Purchase agreement between Alice and Bob")
```

## Add Witness Signatures

```clarity
(contract-call? .notary add-witness
  0x<sha256-hash>
  "I was present and confirm this agreement")
```

## Verify Notarization

```clarity
(contract-call? .notary is-notarized 0x<hash>)
;; Returns: bool

(contract-call? .notary get-notarization 0x<hash>)
;; Returns: { notary, notarized-at, description, witness-count }
```

## Use Cases
- Legal contracts with multiple signatories
- Real estate transaction records
- Business agreement notarization
- Academic degree verification with institutional witness