import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a contract", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("registry", "register-contract",
      [Cl.stringAscii("proofleger3"),
       Cl.standardPrincipal(d),
       Cl.stringAscii("1.0.0"),
       Cl.stringAscii("Core document anchoring contract")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-active returns true after registration", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("registry", "register-contract",
      [Cl.stringAscii("credentials"), Cl.standardPrincipal(d),
       Cl.stringAscii("1.0.0"), Cl.stringAscii("Credentials contract")], d);
    const r = simnet.callReadOnlyFn("registry", "is-active",
      [Cl.stringAscii("credentials")], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects registration from non-admin", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("registry", "register-contract",
      [Cl.stringAscii("fake"), Cl.standardPrincipal(d),
       Cl.stringAscii("0.0.1"), Cl.stringAscii("Fake contract")], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
});