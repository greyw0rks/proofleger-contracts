import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("dispatcher", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a handler", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("dispatcher", "register-handler",
      [Cl.stringAscii("diploma"), Cl.stringAscii("verify"),
       Cl.standardPrincipal(d)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms has-handler after registration", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("dispatcher", "register-handler",
      [Cl.stringAscii("research"), Cl.stringAscii("attest"), Cl.standardPrincipal(d)], d);
    const r = simnet.callReadOnlyFn("dispatcher", "has-handler",
      [Cl.stringAscii("research"), Cl.stringAscii("attest")], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects registration from non-owner", () => {
    const w1 = accounts.get("wallet_1")!;
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("dispatcher", "register-handler",
      [Cl.stringAscii("diploma"), Cl.stringAscii("mint"), Cl.standardPrincipal(d)], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
});