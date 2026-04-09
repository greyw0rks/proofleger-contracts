# ProofLedger Whitelist

The `whitelist.clar` contract manages access to gated features.

## Add to Whitelist

```clarity
;; Owner only
(contract-call? .whitelist add-to-whitelist SP_ADDRESS "premium")
```

## Check Access

```clarity
(contract-call? .whitelist is-whitelisted SP_ADDRESS)
;; Returns: bool
```

## Tiers

Common tier values:
- `"basic"` — standard access
- `"premium"` — advanced features
- `"institution"` — bulk certification access
- `"admin"` — administrative access

## Remove from Whitelist

```clarity
;; Owner only
(contract-call? .whitelist remove-from-whitelist SP_ADDRESS)
```