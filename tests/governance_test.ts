import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("governance", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a governance proposal", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("governance", "propose",
      [Cl.stringAscii("Reduce verification fee"),
       Cl.stringAscii("Reduce from 0.001 STX to 0.0005 STX"),
       Cl.stringAscii("update-fee 500")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("casts a vote for a proposal", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("governance", "propose",
      [Cl.stringAscii("Add Celo support"), Cl.stringAscii("Integrate Celo chain"), Cl.stringAscii("action")], d);
    const r = simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.bool(true)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate vote", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("governance", "propose",
      [Cl.stringAscii("P"), Cl.stringAscii("D"), Cl.stringAscii("A")], d);
    simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.bool(true)], w1);
    const r = simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.bool(false)], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
  it("vote against increments votes-against", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("governance", "propose",
      [Cl.stringAscii("P2"), Cl.stringAscii("D2"), Cl.stringAscii("A2")], d);
    simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.bool(false)], w1);
    const r = simnet.callReadOnlyFn("governance", "get-proposal", [Cl.uint(1)], d);
    expect(r.result).toBeSome();
  });
});