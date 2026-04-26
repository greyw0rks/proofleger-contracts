import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("reputation", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin records anchor and score increases", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("reputation", "record-anchor", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeOk(Cl.uint(10));
  });
  it("slash reduces score", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    for (let i = 0; i < 6; i++)
      simnet.callPublicFn("reputation", "record-anchor", [Cl.standardPrincipal(w1)], d);
    simnet.callPublicFn("reputation", "slash", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("reputation", "get-score-value", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeUint(10); // 60 - 50 = 10
  });
  it("non-admin cannot record anchor", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("reputation", "record-anchor", [Cl.standardPrincipal(w2)], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
  it("score floors at zero after slash", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("reputation", "slash", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("reputation", "get-score-value", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeUint(0);
  });
});