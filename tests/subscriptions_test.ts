import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("subscriptions", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("subscribes to a publisher", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("subscriptions", "subscribe", [Cl.standardPrincipal(w2)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects self-subscription", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("subscriptions", "subscribe", [Cl.standardPrincipal(w1)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("rejects duplicate subscription", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("subscriptions", "subscribe", [Cl.standardPrincipal(w2)], w1);
    const r = simnet.callPublicFn("subscriptions", "subscribe", [Cl.standardPrincipal(w2)], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});