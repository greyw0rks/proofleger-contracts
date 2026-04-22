import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("access-control", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("deployer has admin role by default", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("access-control","has-role",
      [Cl.standardPrincipal(d),Cl.stringAscii("admin")],d);
    expect(r.result).toBeBool(true);
  });
  it("admin grants role to another wallet", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("access-control","grant-role",
      [Cl.standardPrincipal(w1),Cl.stringAscii("issuer")],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("non-admin cannot grant roles", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("access-control","grant-role",
      [Cl.standardPrincipal(w2),Cl.stringAscii("operator")],w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
  it("admin revokes a role", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("access-control","grant-role",
      [Cl.standardPrincipal(w1),Cl.stringAscii("verifier")],d);
    const r = simnet.callPublicFn("access-control","revoke-role",
      [Cl.standardPrincipal(w1),Cl.stringAscii("verifier")],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});