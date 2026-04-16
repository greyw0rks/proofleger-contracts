# ProofLedger Cross-Chain Bridge

The `cross-chain-bridge.clar` contract tracks when proofs are anchored on multiple chains.

## Record a Bridge Event

After anchoring on Stacks, record the Celo anchor:

```clarity
(contract-call? .cross-chain-bridge record-bridge
  0x<sha256-hash>
  "stacks"                                          ;; source chain
  "celo"                                            ;; anchor chain
  "0x251B3302c0CcB1cFBeb0cda3dE06C2D312a41735")    ;; contract address
```

## Confirm Bridge

```clarity
(contract-call? .cross-chain-bridge confirm-bridge 0x<hash> "stacks")
```

## Check Multi-Chain Status

```clarity
(contract-call? .cross-chain-bridge is-multi-chain 0x<hash> "stacks" "celo")
;; Returns: true if anchored on both chains
```

## ProofLedger Multi-Chain Flow

1. Anchor on Stacks via `proofleger3`
2. Anchor on Celo via `ProofLedger.sol`
3. Record bridge on Stacks via `cross-chain-bridge`
4. Document is now verifiable on both Bitcoin and Celo