import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("staking", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("stakes STX successfully", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(100000)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate stake", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("staking", "stake", [Cl.uint(100000)], d);
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(100000)], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("rejects zero amount stake", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("staking", "stake", [Cl.uint(0)], d);
    expect(r.result).toBeErr(Cl.uint(2));
  });
  it("rejects early unstake", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("staking", "stake", [Cl.uint(100000)], d);
    const r = simnet.callPublicFn("staking", "unstake", [], d);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});