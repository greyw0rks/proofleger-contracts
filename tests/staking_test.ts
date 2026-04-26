import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("staking", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("staker locks STX and receives weight", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(5000000)], w1);
    expect(r.result).toBeOk(Cl.uint(5)); // 5 STX = 5 weight
  });
  it("below-minimum stake rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(500000)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("duplicate stake rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("staking", "stake", [Cl.uint(2000000)], w1);
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(2000000)], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
  it("unstake blocked during lock period", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("staking", "stake", [Cl.uint(3000000)], w1);
    const r = simnet.callPublicFn("staking", "unstake", [], w1);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});