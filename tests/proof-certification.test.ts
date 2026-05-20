import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("proof-certification", () => {
  const hash = Buffer.from("ab".repeat(32),"hex");
  const uri = "ipfs://bafycert123";
  it("certified issuer certifies proof", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-certification","add-issuer",[types.principal(d.address),types.uint(2)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-certification","certify",[types.buff(hash),types.ascii("verified"),types.ascii(uri)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects unauthorized issuer", async () => {
    const chain = new Chain(); const [,s] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("proof-certification","certify",[types.buff(hash),types.ascii("standard"),types.ascii(uri)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("prevents double certification", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-certification","add-issuer",[types.principal(d.address),types.uint(3)],d.address)]);
    chain.mineBlock([Tx.contractCall("proof-certification","certify",[types.buff(hash),types.ascii("audited"),types.ascii(uri)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-certification","certify",[types.buff(hash),types.ascii("gold"),types.ascii(uri)],d.address)]);
    expect(b.receipts[0].result).toContain("err u102");
  });
  it("issuer revokes certification", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("proof-certification","add-issuer",[types.principal(d.address),types.uint(5)],d.address),Tx.contractCall("proof-certification","certify",[types.buff(hash),types.ascii("standard"),types.ascii(uri)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("proof-certification","revoke-certification",[types.buff(hash)],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
});