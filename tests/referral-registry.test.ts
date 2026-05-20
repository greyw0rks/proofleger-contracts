import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("referral-registry", () => {
  it("registers referral", async () => {
    const chain = new Chain(); const [d, r] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("referral-registry","register-referral",[types.principal(d.address)],r.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("rejects self-referral", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("referral-registry","register-referral",[types.principal(d.address)],d.address)]);
    expect(b.receipts[0].result).toContain("err u101");
  });
  it("rejects duplicate", async () => {
    const chain = new Chain(); const [d, r] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("referral-registry","register-referral",[types.principal(d.address)],r.address)]);
    const b = chain.mineBlock([Tx.contractCall("referral-registry","register-referral",[types.principal(d.address)],r.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("counts referrals", async () => {
    const chain = new Chain(); const [d,r1,r2] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("referral-registry","register-referral",[types.principal(d.address)],r1.address),Tx.contractCall("referral-registry","register-referral",[types.principal(d.address)],r2.address)]);
    const res = chain.callReadOnlyFn("referral-registry","get-referral-count",[types.principal(d.address)],d.address);
    expect(res.result).toContain("u2");
  });
});