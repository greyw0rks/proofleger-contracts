import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("vote-delegation", () => {
  it("delegates voting power", async () => {
    const chain = new Chain(); const [d, del] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("vote-delegation","delegate-vote",[types.principal(del.address),types.uint(100),types.uint(500),types.ascii("governance")],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects self-delegation", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("vote-delegation","delegate-vote",[types.principal(d.address),types.uint(100),types.uint(500),types.ascii("all")],d.address)]);
    expect(b.receipts[0].result).toContain("err u102");
  });
  it("rejects duplicate delegation", async () => {
    const chain = new Chain(); const [d, del, other] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("vote-delegation","delegate-vote",[types.principal(del.address),types.uint(50),types.uint(300),types.ascii("staking")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("vote-delegation","delegate-vote",[types.principal(other.address),types.uint(50),types.uint(300),types.ascii("staking")],d.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("revokes delegation", async () => {
    const chain = new Chain(); const [d, del] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("vote-delegation","delegate-vote",[types.principal(del.address),types.uint(75),types.uint(1000),types.ascii("all")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("vote-delegation","revoke-delegation",[],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
});