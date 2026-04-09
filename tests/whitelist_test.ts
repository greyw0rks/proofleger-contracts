import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("whitelist", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("adds address to whitelist", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("whitelist", "add-to-whitelist", [Cl.standardPrincipal(w1), Cl.stringAscii("premium")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms is-whitelisted", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("whitelist", "add-to-whitelist", [Cl.standardPrincipal(w1), Cl.stringAscii("basic")], d);
    const r = simnet.callReadOnlyFn("whitelist", "is-whitelisted", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects non-owner adding address", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("whitelist", "add-to-whitelist", [Cl.standardPrincipal(w2), Cl.stringAscii("basic")], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
});