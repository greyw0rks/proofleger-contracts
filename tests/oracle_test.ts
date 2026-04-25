import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("oracle", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("deployer authorizes a reporter", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("oracle", "authorize-reporter",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("authorized reporter updates a feed", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("oracle", "authorize-reporter", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callPublicFn("oracle", "update-feed",
      [Cl.stringAscii("anchor-fee-diploma"), Cl.uint(1500)], w1);
    expect(r.result).toBeOk(Cl.uint(1500));
  });
  it("unauthorized reporter rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("oracle", "update-feed",
      [Cl.stringAscii("anchor-fee-diploma"), Cl.uint(999)], w1);
    expect(r.result).toBeErr(Cl.uint(402));
  });
  it("get-feed returns seeded default value", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("oracle", "get-feed-value",
      [Cl.stringAscii("anchor-fee-diploma")], d);
    expect(r.result).toBeSome(Cl.uint(1000));
  });
});