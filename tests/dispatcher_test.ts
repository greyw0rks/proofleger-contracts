import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("dispatcher", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("owner registers a route", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("dispatcher","register-route",
      [Cl.stringAscii("proofleger"),
       Cl.standardPrincipal(d),
       Cl.stringAscii("3.0.0")],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("get-active-target returns principal after registration", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("dispatcher","register-route",
      [Cl.stringAscii("credentials"),Cl.standardPrincipal(d),Cl.stringAscii("1.0.0")],d);
    const r = simnet.callReadOnlyFn("dispatcher","get-active-target",
      [Cl.stringAscii("credentials")],d);
    expect(r.result).toBeSome();
  });
  it("deactivating a route makes get-active-target return none", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("dispatcher","register-route",
      [Cl.stringAscii("staking"),Cl.standardPrincipal(d),Cl.stringAscii("1.0.0")],d);
    simnet.callPublicFn("dispatcher","deactivate-route",
      [Cl.stringAscii("staking")],d);
    const r = simnet.callReadOnlyFn("dispatcher","get-active-target",
      [Cl.stringAscii("staking")],d);
    expect(r.result).toBeNone();
  });
  it("rejects route registration from non-owner", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("dispatcher","register-route",
      [Cl.stringAscii("fake"),Cl.standardPrincipal(d),Cl.stringAscii("0.0.1")],w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
});