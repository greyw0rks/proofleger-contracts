import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-counter", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin increments anchor count", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("proof-counter", "increment-anchor",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("count reaches 5 correctly", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    for (let i = 0; i < 5; i++)
      simnet.callPublicFn("proof-counter", "increment-anchor", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("proof-counter", "get-anchor-count",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeUint(5);
  });
  it("milestone recorded at count 1", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proof-counter", "increment-anchor", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("proof-counter", "get-milestone",
      [Cl.standardPrincipal(w1), Cl.uint(1)], d);
    expect(r.result).toBeSome();
  });
  it("non-admin cannot increment", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("proof-counter", "increment-anchor",
      [Cl.standardPrincipal(w2)], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
});