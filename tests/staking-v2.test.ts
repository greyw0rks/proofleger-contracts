import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("staking-v2", () => {
  it("stakes above minimum", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("staking-v2","stake",[types.uint(5000000),types.uint(1),types.bool(false)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects duplicate stake", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-v2","stake",[types.uint(5000000),types.uint(1),types.bool(false)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-v2","stake",[types.uint(5000000),types.uint(2),types.bool(true)],d.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("unstake fails before lock ends", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-v2","stake",[types.uint(10000000),types.uint(2),types.bool(true)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-v2","unstake",[],d.address)]);
    expect(b.receipts[0].result).toContain("err u102");
  });
  it("toggles auto-renew flag", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("staking-v2","stake",[types.uint(5000000),types.uint(1),types.bool(false)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("staking-v2","toggle-auto-renew",[],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
});