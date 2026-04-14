import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("snapshots", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("records a snapshot", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("snapshots", "record-snapshot",
      [Cl.uint(500), Cl.uint(120), Cl.uint(1200), Cl.uint(340)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("retrieves latest snapshot", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("snapshots", "record-snapshot",
      [Cl.uint(500), Cl.uint(120), Cl.uint(1200), Cl.uint(340)], d);
    const r = simnet.callReadOnlyFn("snapshots", "get-latest-snapshot", [], d);
    expect(r.result).toBeSome();
  });
  it("increments snapshot count", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("snapshots", "record-snapshot", [Cl.uint(100), Cl.uint(10), Cl.uint(50), Cl.uint(20)], d);
    simnet.callPublicFn("snapshots", "record-snapshot", [Cl.uint(200), Cl.uint(20), Cl.uint(100), Cl.uint(40)], d);
    const r = simnet.callReadOnlyFn("snapshots", "get-snapshot-count", [], d);
    expect(r.result).toBeUint(2);
  });
});