# ProofLedger Access Control

The `access-control.clar` contract manages role-based permissions.

## Roles

| Role | Value | Description |
|---|---|---|
| ADMIN | u1 | Full protocol access |
| ISSUER | u2 | Can issue credentials |
| VERIFIER | u3 | Can verify and attest |
| MODERATOR | u4 | Can flag content |

## Grant a Role

```clarity
;; Owner only
(contract-call? .access-control grant-role SP_ADDRESS u2)
```

## Check Roles

```clarity
(contract-call? .access-control has-role SP_ADDRESS u2)
(contract-call? .access-control is-admin SP_ADDRESS)
(contract-call? .access-control is-issuer SP_ADDRESS)
```

## Revoke

```clarity
(contract-call? .access-control revoke-role SP_ADDRESS u2)
```