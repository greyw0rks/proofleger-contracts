import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("reputation", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("sets a reputation score", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("reputation", "set-reputation", [Cl.standardPrincipal(d), Cl.uint(250), Cl.stringAscii("Expert")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("retrieves a reputation score", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("reputation", "set-reputation", [Cl.standardPrincipal(d), Cl.uint(500), Cl.stringAscii("Authority")], d);
    const r = simnet.callReadOnlyFn("reputation", "get-reputation", [Cl.standardPrincipal(d)], d);
    expect(r.result).toBeSome();
  });
  it("increments total scored count", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("reputation", "set-reputation", [Cl.standardPrincipal(d), Cl.uint(100), Cl.stringAscii("Contributor")], d);
    simnet.callPublicFn("reputation", "set-reputation", [Cl.standardPrincipal(w1), Cl.uint(50), Cl.stringAscii("Builder")], w1);
    const r = simnet.callReadOnlyFn("reputation", "get-total-scored", [], d);
    expect(r.result).toBeUint(2);
  });
});