import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("whitelist", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("institution requests whitelist approval", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("whitelist", "request-approval",
      [Cl.stringAscii("University of Lagos"), Cl.stringAscii("university")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("admin approves issuer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("whitelist", "approve-issuer",
      [Cl.standardPrincipal(w1), Cl.stringAscii("MIT"), Cl.stringAscii("university")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-approved returns true after approval", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("whitelist", "approve-issuer",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Stanford"), Cl.stringAscii("university")], d);
    const r = simnet.callReadOnlyFn("whitelist", "is-approved", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects approval from non-admin", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("whitelist", "approve-issuer",
      [Cl.standardPrincipal(w2), Cl.stringAscii("Fake Uni"), Cl.stringAscii("other")], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
});