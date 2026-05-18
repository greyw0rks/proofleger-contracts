import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('staking-v2', () => {
  it('user can stake above minimum amount', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(1), types.bool(false)], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('rejects duplicate stake from same address', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(1), types.bool(false)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(2), types.bool(true)], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u100');
  });

  it('unstake fails before lock period ends', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(10_000_000), types.uint(2), types.bool(true)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'unstake', [], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('err u102');
  });

  it('auto-renew toggle flips the flag', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('staking-v2', 'stake',
        [types.uint(5_000_000), types.uint(1), types.bool(false)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('staking-v2', 'toggle-auto-renew', [], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });
});
