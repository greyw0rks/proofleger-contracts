import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("research-grant", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a research grant", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("research-grant", "create-grant",
      [Cl.standardPrincipal(w1), Cl.stringAscii("ZK Identity Research"), Cl.uint(10000000)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("adds a milestone", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("research-grant", "create-grant",
      [Cl.standardPrincipal(w1), Cl.stringAscii("AI Research"), Cl.uint(5000000)], d);
    const r = simnet.callPublicFn("research-grant", "add-milestone",
      [Cl.uint(1), Cl.stringAscii("Complete literature review"), Cl.uint(1000000)], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("rejects milestone from non-grantor", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("research-grant", "create-grant",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Grant"), Cl.uint(5000000)], d);
    const r = simnet.callPublicFn("research-grant", "add-milestone",
      [Cl.uint(1), Cl.stringAscii("Milestone"), Cl.uint(1000000)], w2);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});