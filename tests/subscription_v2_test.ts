import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("subscription-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("free tier is always active for any wallet", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callReadOnlyFn("subscription-v2", "is-active",
      [Cl.standardPrincipal(w1), Cl.stringAscii("free")], w1);
    expect(r.result).toBeBool(true);
  });
  it("get-tier-price returns pro price", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("subscription-v2", "get-tier-price",
      [Cl.stringAscii("pro")], d);
    expect(r.result).toBeSome();
  });
  it("invalid tier returns err u1", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("subscription-v2", "subscribe",
      [Cl.stringAscii("platinum")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("pro tier inactive before subscription", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callReadOnlyFn("subscription-v2", "is-active",
      [Cl.standardPrincipal(w1), Cl.stringAscii("pro")], w1);
    expect(r.result).toBeBool(false);
  });
});