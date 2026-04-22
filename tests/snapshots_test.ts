import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("snapshots", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("takes a snapshot", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("snapshots","take-snapshot",
      [Cl.uint(500),Cl.uint(380),Cl.uint(120),Cl.stringAscii("Daily snapshot Apr 23")],d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("reads latest snapshot", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("snapshots","take-snapshot",
      [Cl.uint(600),Cl.uint(400),Cl.uint(140),Cl.stringAscii("Test snapshot")],d);
    const r = simnet.callReadOnlyFn("snapshots","get-latest-snapshot",[],d);
    expect(r.result).toBeSome();
  });
  it("rejects second snapshot too soon", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("snapshots","take-snapshot",
      [Cl.uint(100),Cl.uint(50),Cl.uint(30),Cl.stringAscii("first")],d);
    const r = simnet.callPublicFn("snapshots","take-snapshot",
      [Cl.uint(101),Cl.uint(51),Cl.uint(31),Cl.stringAscii("too soon")],d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});