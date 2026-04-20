import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("reputation", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("records an anchor and increments score", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("reputation", "record-anchor", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("reputation", "get-score", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeUint(10);
  });
  it("accumulates score from multiple activities", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("reputation", "record-anchor", [Cl.standardPrincipal(w1)], d);
    simnet.callPublicFn("reputation", "record-attest", [Cl.standardPrincipal(w1)], d);
    simnet.callPublicFn("reputation", "record-nft",    [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("reputation", "get-score", [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeUint(40); // 10 + 5 + 25
  });
  it("rejects unauthorized record", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("reputation", "record-anchor", [Cl.standardPrincipal(w2)], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
});