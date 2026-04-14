import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("access-control", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("grants a role", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("access-control", "grant-role",
      [Cl.standardPrincipal(w1), Cl.uint(2)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms has-role after grant", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("access-control", "grant-role", [Cl.standardPrincipal(w1), Cl.uint(3)], d);
    const r = simnet.callReadOnlyFn("access-control", "has-role",
      [Cl.standardPrincipal(w1), Cl.uint(3)], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects grant from non-owner", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("access-control", "grant-role",
      [Cl.standardPrincipal(w2), Cl.uint(2)], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
  it("revokes a role", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("access-control", "grant-role", [Cl.standardPrincipal(w1), Cl.uint(2)], d);
    const r = simnet.callPublicFn("access-control", "revoke-role", [Cl.standardPrincipal(w1), Cl.uint(2)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});