# ProofLedger Publications

The `publication.clar` contract creates an on-chain academic publication registry.

## Publish a Paper

```clarity
(contract-call? .publication publish
  0x<full-paper-hash>
  "Zero-Knowledge Proofs in Identity Systems"
  0x<abstract-hash>
  "10.1234/zk-identity-2026"  ;; DOI
  "research")                  ;; type
```

## Cite a Paper

```clarity
(contract-call? .publication cite
  0x<citing-paper-hash>
  0x<cited-paper-hash>)
```

## Get Citation Count

```clarity
(contract-call? .publication get-citation-count 0x<hash>)
```

## Publication Types

`research`, `review`, `conference`, `preprint`, `thesis`, `patent`, `other`