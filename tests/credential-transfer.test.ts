import { describe, it, expect } from 'vitest';
import { Clarinet, Tx, Chain, Account, types } from '@hirosystems/clarinet-sdk';

describe('credential-transfer', () => {
  it('issues a transferable credential to a holder', async () => {
    const chain = new Chain();
    const [deployer, holder] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('membership-v1'), types.bool(true), types.uint(3)], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('membership-v1')], deployer.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('holder can transfer to another address', async () => {
    const chain = new Chain();
    const [deployer, holder, receiver] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('pass-v1'), types.bool(true), types.uint(5)], deployer.address),
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('pass-v1')], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'transfer-credential',
        [types.uint(1), types.principal(receiver.address)], holder.address),
    ]);
    expect(block.receipts[0].result).toContain('ok');
  });

  it('rejects transfer for non-transferable schema', async () => {
    const chain = new Chain();
    const [deployer, holder, receiver] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('sbt-v1'), types.bool(false), types.uint(0)], deployer.address),
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('sbt-v1')], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'transfer-credential',
        [types.uint(1), types.principal(receiver.address)], holder.address),
    ]);
    expect(block.receipts[0].result).toContain('err u101');
  });

  it('rejects transfer from non-holder address', async () => {
    const chain = new Chain();
    const [deployer, holder, stranger] = chain.accounts.values() as Account[];
    chain.mineBlock([
      Tx.contractCall('credential-transfer', 'set-transfer-policy',
        [types.ascii('ticket-v1'), types.bool(true), types.uint(2)], deployer.address),
      Tx.contractCall('credential-transfer', 'issue-credential',
        [types.principal(holder.address), types.ascii('ticket-v1')], deployer.address),
    ]);
    const block = chain.mineBlock([
      Tx.contractCall('credential-transfer', 'transfer-credential',
        [types.uint(1), types.principal(stranger.address)], stranger.address),
    ]);
    expect(block.receipts[0].result).toContain('err u102');
  });
});
