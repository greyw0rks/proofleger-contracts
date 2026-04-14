import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("fee-collector", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("reads default fee", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("fee-collector", "get-fee", [], d);
    expect(r.result).toBeUint(1000);
  });
  it("updates fee (owner only)", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("fee-collector", "set-fee", [Cl.uint(2000)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects fee update from non-owner", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("fee-collector", "set-fee", [Cl.uint(9999)], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
  it("adds a fee recipient", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("fee-collector", "add-recipient",
      [Cl.standardPrincipal(w1), Cl.uint(50)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});