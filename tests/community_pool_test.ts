import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("community-pool", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("accepts a contribution", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("community-pool", "contribute", [Cl.uint(500000)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects zero contribution", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("community-pool", "contribute", [Cl.uint(0)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("rejects grant from non-owner", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("community-pool", "grant",
      [Cl.standardPrincipal(w2), Cl.uint(100), Cl.stringAscii("Hack")], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
});