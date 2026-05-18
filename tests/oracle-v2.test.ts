import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('oracle-v2', () => {
  it('authorized feeder can submit price', async () => {
    const chain = new Chain();
    const [deployer, feeder] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('oracle-v2', 'authorize-feeder',
        [types.principal(feeder.address)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('oracle-v2', 'submit-price',
        [types.ascii('STX'), types.uint(1_500_000)], feeder.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('unauthorized feeder is rejected', async () => {
    const chain = new Chain();
    const [, stranger] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('oracle-v2', 'submit-price',
        [types.ascii('BTC'), types.uint(60_000_000_000)], stranger.address),
    ]);
    expect(block.receipts[0].result).toContain('err u100');
  });

  it('aggregates price from multiple sources', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    const block = chain.mineBlock([
      Tx.contractCall('oracle-v2', 'aggregate-price',
        [types.ascii('STX'), types.list([
          types.uint(1_400_000),
          types.uint(1_500_000),
          types.uint(1_600_000),
        ])], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('returns error for stale price feed', async () => {
    const chain = new Chain();
    const [deployer] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('oracle-v2', 'aggregate-price',
        [types.ascii('CELO'), types.list([types.uint(500_000), types.uint(520_000)])],
        deployer.address),
    ]);
    chain.mineEmptyBlock(25);
    const result = chain.callReadOnlyFn('oracle-v2', 'get-price',
      [types.ascii('CELO')], deployer.address);
    expect(result.result).toContain('err u102');
  });
});
