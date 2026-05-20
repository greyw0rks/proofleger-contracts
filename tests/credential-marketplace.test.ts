import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-marketplace", () => {
  const hash = Buffer.from("ab".repeat(32),"hex");
  it("lists credential", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("credential-marketplace","list-credential",[types.buff(hash),types.uint(1000000),types.ascii("degree-v1")],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("buyer purchases listing", async () => {
    const chain = new Chain(); const [d, buyer] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-marketplace","list-credential",[types.buff(hash),types.uint(500000),types.ascii("cert")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-marketplace","buy-credential",[types.uint(1)],buyer.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("seller delists", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-marketplace","list-credential",[types.buff(hash),types.uint(250000),types.ascii("kyc")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-marketplace","delist-credential",[types.uint(1)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects double purchase", async () => {
    const chain = new Chain(); const [d, buyer] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-marketplace","list-credential",[types.buff(hash),types.uint(100000),types.ascii("badge")],d.address)]);
    chain.mineBlock([Tx.contractCall("credential-marketplace","buy-credential",[types.uint(1)],buyer.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-marketplace","buy-credential",[types.uint(1)],buyer.address)]);
    expect(b.receipts[0].result).toContain("err u104");
  });
});