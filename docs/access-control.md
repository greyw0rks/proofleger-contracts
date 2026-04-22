# ProofLedger Access Control

The `access-control.clar` contract manages role-based permissions across the protocol.

## Built-in Roles

| Role | Purpose |
|---|---|
| `admin` | Manage roles and system settings |
| `issuer` | Issue credentials and certificates |
| `verifier` | Perform verification operations |
| `operator` | Run automated processes |

## Grant a Role

```clarity
;; Admin only
(contract-call? .access-control grant-role
  SP_INSTITUTION_ADDRESS
  "issuer")
```

## Check a Role

```clarity
(contract-call? .access-control has-role SP_ADDRESS "issuer")
;; Returns: bool
```

## Revoke a Role

```clarity
(contract-call? .access-control revoke-role SP_ADDRESS "operator")
```