import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("referral-reward", () => {
  it("owner funds pool", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("referral-reward","fund-pool",[types.uint(10000000)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("sets tier multiplier", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("referral-reward","set-tier-multiplier",[types.uint(10),types.uint(3)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("claimant receives reward", async () => {
    const chain = new Chain(); const [d, c] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("referral-reward","fund-pool",[types.uint(50000000)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("referral-reward","claim-rewards",[types.uint(3)],c.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects double claim", async () => {
    const chain = new Chain(); const [d, c] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("referral-reward","fund-pool",[types.uint(50000000)],d.address)]);
    chain.mineBlock([Tx.contractCall("referral-reward","claim-rewards",[types.uint(2)],c.address)]);
    const b = chain.mineBlock([Tx.contractCall("referral-reward","claim-rewards",[types.uint(2)],c.address)]);
    expect(b.receipts[0].result).toContain("err u101");
  });
});