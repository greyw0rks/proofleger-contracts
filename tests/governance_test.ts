import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("governance", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("any principal can create a proposal", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("governance", "propose",
      [Cl.stringAscii("Enable whitelist"), Cl.stringAscii("Restrict anchoring to verified issuers")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("staker casts a weighted vote in favor", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("governance", "propose",
      [Cl.stringAscii("Fee adjustment"), Cl.stringAscii("Lower anchor fee to 500 uSTX")], w1);
    const r = simnet.callPublicFn("governance", "vote",
      [Cl.uint(1), Cl.uint(10), Cl.bool(true)], w2);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("duplicate vote rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("governance", "propose",
      [Cl.stringAscii("Proposal X"), Cl.stringAscii("desc")], w1);
    simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.uint(5), Cl.bool(true)], w1);
    const r = simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.uint(5), Cl.bool(false)], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
  it("proposal count increments per submission", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("governance", "propose", [Cl.stringAscii("P1"), Cl.stringAscii("d1")], w1);
    simnet.callPublicFn("governance", "propose", [Cl.stringAscii("P2"), Cl.stringAscii("d2")], w1);
    const r = simnet.callReadOnlyFn("governance", "get-proposal-count", [], w1);
    expect(r.result).toBeUint(2);
  });
});