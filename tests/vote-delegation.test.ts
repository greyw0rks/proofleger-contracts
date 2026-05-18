import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('vote-delegation', () => {
  it('user can delegate voting power', async () => {
    const chain = new Chain();
    const [deployer, delegate] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(delegate.address), types.uint(100), types.uint(500), types.ascii('governance')],
        deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('rejects self-delegation', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(deployer.address), types.uint(100), types.uint(500), types.ascii('all')],
        deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u102');
  });

  it('rejects duplicate delegation', async () => {
    const chain = new Chain();
    const [deployer, delegate, other] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(delegate.address), types.uint(50), types.uint(300), types.ascii('staking')],
        deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(other.address), types.uint(50), types.uint(300), types.ascii('staking')],
        deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u100');
  });

  it('delegator can revoke their delegation', async () => {
    const chain = new Chain();
    const [deployer, delegate] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('vote-delegation', 'delegate-vote',
        [types.principal(delegate.address), types.uint(75), types.uint(1000), types.ascii('all')],
        deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('vote-delegation', 'revoke-delegation', [], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });
});
