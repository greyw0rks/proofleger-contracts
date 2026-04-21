import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("subscriptions", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("subscribes to basic tier", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("subscriptions", "subscribe",
      [Cl.stringAscii("basic")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-subscribed returns true", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("subscriptions", "subscribe", [Cl.stringAscii("basic")], w1);
    const r = simnet.callReadOnlyFn("subscriptions", "is-subscribed",
      [Cl.standardPrincipal(w1)], w1);
    expect(r.result).toBeBool(true);
  });
  it("rejects unknown tier", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("subscriptions", "subscribe",
      [Cl.stringAscii("ultra-pro")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});