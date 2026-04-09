import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("referrals", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a referral", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("referrals", "register-referral", [Cl.standardPrincipal(w1)], w2);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects self-referral", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("referrals", "register-referral", [Cl.standardPrincipal(w1)], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
  it("rejects duplicate referral", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("referrals", "register-referral", [Cl.standardPrincipal(w1)], w2);
    const r = simnet.callPublicFn("referrals", "register-referral", [Cl.standardPrincipal(w1)], w2);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("counts referrals correctly", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const w3 = accounts.get("wallet_3")!;
    simnet.callPublicFn("referrals", "register-referral", [Cl.standardPrincipal(w1)], w2);
    simnet.callPublicFn("referrals", "register-referral", [Cl.standardPrincipal(w1)], w3);
    const r = simnet.callReadOnlyFn("referrals", "get-referral-count", [Cl.standardPrincipal(w1)], w1);
    expect(r.result).toBeUint(2);
  });
});