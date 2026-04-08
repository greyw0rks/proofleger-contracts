# ProofLedger Error Codes

## proofleger3.clar
| Code | Meaning |
|---|---|
| u100 | Hash already anchored |
| u101 | Invalid hash |
| u102 | Hash not found |
| u103 | Cannot self-attest |
| u104 | Already attested |

## credentials.clar
| Code | Meaning |
|---|---|
| u100 | Credential already exists |
| u403 | Not the original issuer |
| u404 | Credential not found |

## achievements.clar
| Code | Meaning |
|---|---|
| u1 | NFT already minted for this hash |
| u500 | Transfer blocked (soulbound) |

## revocations.clar
| Code | Meaning |
|---|---|
| u1 | Already revoked |

## governance.clar
| Code | Meaning |
|---|---|
| u1 | Proposal not found |
| u2 | Proposal is closed |
| u3 | Already voted |

## registry.clar
| Code | Meaning |
|---|---|
| u1 | Already registered |
| u403 | Not contract owner |
| u404 | Issuer not found |

## badges.clar
| Code | Meaning |
|---|---|
| u1 | Badge ID already exists |
| u2 | Badge not found |
| u3 | Already issued this badge |

## subscriptions.clar
| Code | Meaning |
|---|---|
| u1 | Cannot subscribe to self |
| u2 | Already subscribed |
| u3 | Subscription not found |