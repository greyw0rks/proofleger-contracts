import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("staking", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("stakes STX", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(1000000)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects zero stake", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(0)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("rejects double stake", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("staking", "stake", [Cl.uint(1000000)], w1);
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(500000)], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
  it("unstakes and gets STX back", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("staking", "stake", [Cl.uint(1000000)], w1);
    const r = simnet.callPublicFn("staking", "unstake", [], w1);
    expect(r.result).toBeOk(Cl.uint(1000000));
  });
});