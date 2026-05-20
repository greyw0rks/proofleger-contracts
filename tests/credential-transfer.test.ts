import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("credential-transfer", () => {
  it("issues transferable credential", async () => {
    const chain = new Chain(); const [d, h] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-transfer","set-transfer-policy",[types.ascii("membership-v1"),types.bool(true),types.uint(3)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-transfer","issue-credential",[types.principal(h.address),types.ascii("membership-v1")],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("holder transfers to new address", async () => {
    const chain = new Chain(); const [d, h, r] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-transfer","set-transfer-policy",[types.ascii("pass-v1"),types.bool(true),types.uint(5)],d.address),Tx.contractCall("credential-transfer","issue-credential",[types.principal(h.address),types.ascii("pass-v1")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-transfer","transfer-credential",[types.uint(1),types.principal(r.address)],h.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects non-transferable schema", async () => {
    const chain = new Chain(); const [d, h, r] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-transfer","set-transfer-policy",[types.ascii("sbt-v1"),types.bool(false),types.uint(0)],d.address),Tx.contractCall("credential-transfer","issue-credential",[types.principal(h.address),types.ascii("sbt-v1")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-transfer","transfer-credential",[types.uint(1),types.principal(r.address)],h.address)]);
    expect(b.receipts[0].result).toContain("err u101");
  });
  it("rejects transfer from non-holder", async () => {
    const chain = new Chain(); const [d, h, s] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("credential-transfer","set-transfer-policy",[types.ascii("ticket-v1"),types.bool(true),types.uint(2)],d.address),Tx.contractCall("credential-transfer","issue-credential",[types.principal(h.address),types.ascii("ticket-v1")],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("credential-transfer","transfer-credential",[types.uint(1),types.principal(s.address)],s.address)]);
    expect(b.receipts[0].result).toContain("err u102");
  });
});