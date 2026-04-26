import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("delegation", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("delegator grants rights to delegate", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("delegation", "grant",
      [Cl.standardPrincipal(w2), Cl.uint(0), Cl.bool(false)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("delegate is authorized after grant", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("delegation", "grant",
      [Cl.standardPrincipal(w2), Cl.uint(0), Cl.bool(false)], w1);
    const r = simnet.callReadOnlyFn("delegation", "is-authorized",
      [Cl.standardPrincipal(w2), Cl.standardPrincipal(w1)], w1);
    expect(r.result).toBeBool(true);
  });
  it("revoke removes delegation", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("delegation", "grant",
      [Cl.standardPrincipal(w2), Cl.uint(0), Cl.bool(false)], w1);
    simnet.callPublicFn("delegation", "revoke", [], w1);
    const r = simnet.callReadOnlyFn("delegation", "is-authorized",
      [Cl.standardPrincipal(w2), Cl.standardPrincipal(w1)], w1);
    expect(r.result).toBeBool(false);
  });
  it("duplicate grant rejected", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("delegation", "grant",
      [Cl.standardPrincipal(w2), Cl.uint(0), Cl.bool(false)], w1);
    const r = simnet.callPublicFn("delegation", "grant",
      [Cl.standardPrincipal(w2), Cl.uint(0), Cl.bool(false)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});