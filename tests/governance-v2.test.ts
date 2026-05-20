import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("governance-v2", () => {
  it("creates proposal", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("governance-v2","create-proposal",[types.ascii("Test")],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("casts vote", async () => {
    const chain = new Chain(); const [d, v] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-v2","create-proposal",[types.ascii("Vote test")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-v2","cast-vote",[types.uint(1),types.bool(true)],v.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects duplicate vote", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-v2","create-proposal",[types.ascii("Dupe")],d.address)]);
    chain.mineBlock([Tx.contractCall("governance-v2","cast-vote",[types.uint(1),types.bool(true)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("governance-v2","cast-vote",[types.uint(1),types.bool(false)],d.address)]);
    expect(b.receipts[0].result).toContain("err u102");
  });
  it("fails execution without quorum", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("governance-v2","create-proposal",[types.ascii("No quorum")],d.address)]);
    chain.mineEmptyBlock(1441);
    const b = chain.mineBlock([Tx.contractCall("governance-v2","execute-proposal",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("err u104");
  });
});