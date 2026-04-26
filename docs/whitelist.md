# ProofLedger Whitelist

The `whitelist.clar` contract provides an optional permission layer.
By default the whitelist is **disabled** — anyone can anchor.
When enabled, only explicitly added addresses may submit.

## Enable / Disable

```clarity
;; Enable (admin only)
(contract-call? .whitelist set-enabled true)

;; Disable (open access)
(contract-call? .whitelist set-enabled false)
```

## Add / Remove Addresses

```clarity
(contract-call? .whitelist add SP_MIT_ADDRESS "MIT issuer wallet")
(contract-call? .whitelist remove SP_MIT_ADDRESS)
```

## Check Access

```clarity
(contract-call? .whitelist is-allowed SP_ADDRESS)
;; true when disabled, or address is active in list
```

## Integration

Anchor contracts check `is-allowed` before processing:

```clarity
(asserts! (contract-call? .whitelist is-allowed tx-sender) (err u403))
```