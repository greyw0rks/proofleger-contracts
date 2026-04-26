import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("recovery", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("owner sets up recovery with two guardians", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const w3 = accounts.get("wallet_3")!;
    const r = simnet.callPublicFn("recovery", "setup-recovery",
      [Cl.standardPrincipal(w2), Cl.standardPrincipal(w3), Cl.uint(1)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("duplicate setup rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const w3 = accounts.get("wallet_3")!;
    simnet.callPublicFn("recovery", "setup-recovery",
      [Cl.standardPrincipal(w2), Cl.standardPrincipal(w3), Cl.uint(1)], w1);
    const r = simnet.callPublicFn("recovery", "setup-recovery",
      [Cl.standardPrincipal(w2), Cl.standardPrincipal(w3), Cl.uint(1)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("guardian initiates recovery", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const w3 = accounts.get("wallet_3")!;
    const w4 = accounts.get("wallet_4")!;
    simnet.callPublicFn("recovery", "setup-recovery",
      [Cl.standardPrincipal(w2), Cl.standardPrincipal(w3), Cl.uint(1)], w1);
    const r = simnet.callPublicFn("recovery", "initiate-recovery",
      [Cl.standardPrincipal(w1), Cl.standardPrincipal(w4)], w2);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("non-guardian cannot initiate recovery", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const w3 = accounts.get("wallet_3")!;
    const w5 = accounts.get("wallet_5")!;
    simnet.callPublicFn("recovery", "setup-recovery",
      [Cl.standardPrincipal(w2), Cl.standardPrincipal(w3), Cl.uint(1)], w1);
    const r = simnet.callPublicFn("recovery", "initiate-recovery",
      [Cl.standardPrincipal(w1), Cl.standardPrincipal(w5)], w5);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});