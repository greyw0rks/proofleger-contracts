import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-stamp", () => {
  const hash = Buffer.from("aa".repeat(32),"hex");
  it("authorized stamper issues stamp", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-stamp","authorize-stamper",[types.principal(d.address)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-stamp","issue-stamp",[types.buff(hash),types.ascii("gold"),types.uint(2000),types.ascii("Verified")],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("unauthorized cannot issue", async () => {
    const chain = new Chain(); const [,s] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-stamp","issue-stamp",[types.buff(hash),types.ascii("silver"),types.uint(500),types.ascii("Unauth")],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("prevents duplicate stamp", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-stamp","authorize-stamper",[types.principal(d.address)],d.address)]);
    chain.mineBlock([Tx.contractCall("proof-stamp","issue-stamp",[types.buff(hash),types.ascii("bronze"),types.uint(1000),types.ascii("First")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-stamp","issue-stamp",[types.buff(hash),types.ascii("gold"),types.uint(1000),types.ascii("Dupe")],d.address)]);
    expect(b.receipts[0].result).toContain("err u102");
  });
  it("stamp valid within window", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-stamp","authorize-stamper",[types.principal(d.address)],d.address),Tx.contractCall("proof-stamp","issue-stamp",[types.buff(hash),types.ascii("platinum"),types.uint(5000),types.ascii("Long")],d.address)]);
    const r = chain.callReadOnlyFn("proof-stamp","is-valid-stamp?",[types.buff(hash),types.principal(d.address)],d.address);
    expect(r.result).toBe("true");
  });
});