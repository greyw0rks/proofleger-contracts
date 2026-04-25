import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("timelock", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("owner queues an action", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("timelock", "queue-action",
      [Cl.stringAscii("Upgrade proofleger-v4")], d);
    expect(r.result).toBeOk();
  });
  it("non-owner cannot queue", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("timelock", "queue-action",
      [Cl.stringAscii("Malicious action")], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
  it("action not executable before delay", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("timelock", "queue-action", [Cl.stringAscii("test action")], d);
    const r = simnet.callPublicFn("timelock", "execute-action", [Cl.uint(1)], d);
    expect(r.result).toBeErr(Cl.uint(403));
  });
  it("owner can cancel a queued action", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("timelock", "queue-action", [Cl.stringAscii("cancel this")], d);
    const r = simnet.callPublicFn("timelock", "cancel-action", [Cl.uint(1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});