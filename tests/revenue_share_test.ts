import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("revenue-share", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin allocates revenue to a staker", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("revenue-share", "allocate",
      [Cl.standardPrincipal(w1), Cl.uint(500000)], d);
    expect(r.result).toBeOk(Cl.uint(500000));
  });
  it("get-claimable returns allocated amount", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("revenue-share", "allocate",
      [Cl.standardPrincipal(w1), Cl.uint(250000)], d);
    const r = simnet.callReadOnlyFn("revenue-share", "get-claimable",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeUint(250000);
  });
  it("non-admin cannot allocate", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("revenue-share", "allocate",
      [Cl.standardPrincipal(w2), Cl.uint(100000)], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
  it("claim with nothing reverts", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("revenue-share", "claim", [], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});