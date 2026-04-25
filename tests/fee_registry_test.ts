import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("fee-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin sets a fee", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("fee-registry", "set-fee",
      [Cl.stringAscii("anchor"), Cl.uint(2000), Cl.bool(true)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("non-admin cannot set fee", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("fee-registry", "set-fee",
      [Cl.stringAscii("anchor"), Cl.uint(0), Cl.bool(false)], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
  it("disabled fee returns none from get-fee-amount", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("fee-registry", "get-fee-amount",
      [Cl.stringAscii("anchor")], d); // seeded as disabled
    expect(r.result).toBeNone();
  });
  it("admin updates treasury address", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("fee-registry", "set-treasury",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});