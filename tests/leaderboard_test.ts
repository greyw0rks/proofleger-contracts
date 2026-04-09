import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("leaderboard", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("updates a rank entry", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("leaderboard", "update-rank", [Cl.standardPrincipal(w1), Cl.uint(1), Cl.uint(500)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("retrieves rank by position", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("leaderboard", "update-rank", [Cl.standardPrincipal(w1), Cl.uint(1), Cl.uint(500)], d);
    const r = simnet.callReadOnlyFn("leaderboard", "get-rank", [Cl.uint(1)], d);
    expect(r.result).toBeSome();
  });
  it("retrieves user rank by address", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("leaderboard", "update-rank", [Cl.standardPrincipal(w1), Cl.uint(3), Cl.uint(250)], d);
    const r = simnet.callReadOnlyFn("leaderboard", "get-user-rank", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeSome();
  });
});