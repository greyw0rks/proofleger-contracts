import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("audit-trail", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("any principal logs an action with open-writes", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("audit-trail", "log",
      [Cl.stringAscii("anchor"), Cl.stringAscii("proofleger3"),
       Cl.stringAscii("Anchored diploma")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("entry count increments", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("audit-trail", "log",
      [Cl.stringAscii("admin"), Cl.stringAscii("whitelist"),
       Cl.stringAscii("Added MIT")], d);
    const r = simnet.callReadOnlyFn("audit-trail", "get-entry-count", [], d);
    expect(r.result).toBeUint(1);
  });
  it("admin can lock writes", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("audit-trail", "set-open-writes", [Cl.bool(false)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("get-entry returns stored action", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("audit-trail", "log",
      [Cl.stringAscii("verify"), Cl.stringAscii("hash-abc"),
       Cl.stringAscii("Spot check")], d);
    const r = simnet.callReadOnlyFn("audit-trail", "get-entry", [Cl.uint(1)], d);
    expect(r.result).toBeSome();
  });
});