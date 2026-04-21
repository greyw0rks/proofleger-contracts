# ProofLedger Multi-Party Notarization

The `notary.clar` contract enables independent witness signatures on document proofs.

## Initiate Notarization

```clarity
(contract-call? .notary initiate-notarization
  0x<document-hash>
  "Service Agreement Q2 2026")
```

## Witness Signs

Any wallet (not the initiator) can add their witness signature:

```clarity
(contract-call? .notary witness-sign
  0x<document-hash>
  "I confirm this document was reviewed and approved")
```

## Finalize

Once enough witnesses have signed, the initiator finalizes:

```clarity
(contract-call? .notary finalize 0x<hash>)
```

## Read Status

```clarity
(contract-call? .notary get-notarization 0x<hash>)
;; Returns: { initiator, title, witness-count, finalized }

(contract-call? .notary is-finalized 0x<hash>)  ;; bool
```

## Use Cases
- Legal contracts requiring independent witnesses
- Property deed transfers with multiple parties
- Academic credential verification with faculty witnesses