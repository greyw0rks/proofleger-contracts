# ProofLedger Contract Ecosystem

## Interaction Map

```
User
 ├── proofleger3       (anchor documents)
 ├── credentials       (issue/receive credentials)
 ├── achievements      (mint/hold NFTs)
 ├── endorsements      (endorse documents)
 ├── profiles          (manage on-chain profile)
 ├── collections       (group documents)
 ├── staking           (stake STX)
 ├── referrals         (track referrals)
 └── subscriptions     (follow wallets)

Institution
 ├── registry          (register as trusted issuer)
 ├── certifier         (batch certify documents)
 └── whitelist         (access control)

Community
 ├── badges            (create/issue badges)
 ├── governance        (propose/vote)
 ├── messaging         (on-chain messages)
 └── leaderboard       (contributor rankings)

Infrastructure
 ├── reputation        (score storage)
 ├── revocations       (document revocation)
 ├── timestamps        (general anchoring)
 └── oracle            (data feeds)
```