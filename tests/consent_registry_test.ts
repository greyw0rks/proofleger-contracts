import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("consent-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("grants consent", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("consent-registry", "grant-consent",
      [Cl.standardPrincipal(w1), Cl.stringAscii("data-analytics"), Cl.none(), Cl.none()], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("has-valid-consent returns true", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("consent-registry", "grant-consent",
      [Cl.standardPrincipal(w1), Cl.stringAscii("marketing"), Cl.none(), Cl.none()], d);
    const r = simnet.callReadOnlyFn("consent-registry", "has-valid-consent",
      [Cl.standardPrincipal(d), Cl.standardPrincipal(w1), Cl.stringAscii("marketing")], d);
    expect(r.result).toBeBool(true);
  });
  it("revokes consent", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("consent-registry", "grant-consent",
      [Cl.standardPrincipal(w1), Cl.stringAscii("profiling"), Cl.none(), Cl.none()], d);
    const r = simnet.callPublicFn("consent-registry", "revoke-consent",
      [Cl.standardPrincipal(w1), Cl.stringAscii("profiling")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects self-consent", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("consent-registry", "grant-consent",
      [Cl.standardPrincipal(d), Cl.stringAscii("self"), Cl.none(), Cl.none()], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});