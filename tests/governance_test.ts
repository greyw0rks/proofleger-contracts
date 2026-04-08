import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("governance", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a proposal and returns id", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("governance", "create-proposal", [Cl.stringAscii("Add feature X"), Cl.stringAscii("Description here")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("votes yes on a proposal", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("governance", "create-proposal", [Cl.stringAscii("P1"), Cl.stringAscii("d")], d);
    const r = simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.bool(true)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate vote", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("governance", "create-proposal", [Cl.stringAscii("P2"), Cl.stringAscii("d")], d);
    simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.bool(true)], w1);
    const r = simnet.callPublicFn("governance", "vote", [Cl.uint(1), Cl.bool(false)], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});