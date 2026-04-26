import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("payment-splitter", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin adds a recipient", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("payment-splitter", "add-recipient",
      [Cl.standardPrincipal(w1), Cl.uint(50), Cl.stringAscii("dev fund")], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("non-admin cannot add recipient", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("payment-splitter", "add-recipient",
      [Cl.standardPrincipal(w2), Cl.uint(25), Cl.stringAscii("hack")], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
  it("get-payout returns proportional amount", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("payment-splitter", "add-recipient",
      [Cl.standardPrincipal(w1), Cl.uint(50), Cl.stringAscii("r0")], d);
    const r = simnet.callReadOnlyFn("payment-splitter", "get-payout",
      [Cl.uint(1000000), Cl.uint(0)], d);
    expect(r.result).toBeUint(1000000); // 100% for single recipient
  });
  it("recipient count increments", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("payment-splitter", "add-recipient",
      [Cl.standardPrincipal(w1), Cl.uint(100), Cl.stringAscii("r0")], d);
    const r = simnet.callReadOnlyFn("payment-splitter", "get-recipient-count", [], d);
    expect(r.result).toBeUint(1);
  });
});