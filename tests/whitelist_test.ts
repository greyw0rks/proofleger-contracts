import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("whitelist", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("all addresses allowed when whitelist disabled", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("whitelist", "is-allowed", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(true);
  });
  it("admin adds address to whitelist", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("whitelist", "add",
      [Cl.standardPrincipal(w1), Cl.stringAscii("test wallet")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("non-admin cannot add to whitelist", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("whitelist", "add",
      [Cl.standardPrincipal(w2), Cl.stringAscii("hack attempt")], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
  it("removed address not allowed when whitelist enabled", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("whitelist", "add", [Cl.standardPrincipal(w1), Cl.stringAscii("wallet")], d);
    simnet.callPublicFn("whitelist", "remove", [Cl.standardPrincipal(w1)], d);
    simnet.callPublicFn("whitelist", "set-enabled", [Cl.bool(true)], d);
    const r = simnet.callReadOnlyFn("whitelist", "is-allowed", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(false);
  });
});