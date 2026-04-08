import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("messaging", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("sends a message", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("messaging", "send-message", [Cl.stringAscii("Hello blockchain"), Cl.none()], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("sends message with reference hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("messaging", "send-message", [Cl.stringAscii("See attached proof"), Cl.some(hash)], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("increments message count", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("messaging", "send-message", [Cl.stringAscii("msg1"), Cl.none()], d);
    simnet.callPublicFn("messaging", "send-message", [Cl.stringAscii("msg2"), Cl.none()], d);
    const r = simnet.callReadOnlyFn("messaging", "get-message-count", [Cl.standardPrincipal(d)], d);
    expect(r.result).toBeUint(2);
  });
});