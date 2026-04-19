import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("oracle", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("owner updates a feed", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("oracle", "update-feed",
      [Cl.stringAscii("STX-USD"), Cl.uint(100), Cl.stringAscii("STX/USD price feed")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("reads feed value", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("oracle", "update-feed",
      [Cl.stringAscii("BTC-USD"), Cl.uint(9400000), Cl.stringAscii("BTC/USD price")], d);
    const r = simnet.callReadOnlyFn("oracle", "get-feed-value", [Cl.stringAscii("BTC-USD")], d);
    expect(r.result).toBeSome(Cl.uint(9400000));
  });
  it("rejects unauthorized feed update", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("oracle", "update-feed",
      [Cl.stringAscii("ETH-USD"), Cl.uint(3000), Cl.stringAscii("price")], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
  it("authorized updater can update", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("oracle", "authorize-updater", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callPublicFn("oracle", "update-feed",
      [Cl.stringAscii("CELO-USD"), Cl.uint(75), Cl.stringAscii("CELO/USD")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});