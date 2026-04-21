import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("messaging", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("sends a message", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("messaging", "send-message",
      [Cl.standardPrincipal(w1), hash], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("recipient marks message as read", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("messaging", "send-message", [Cl.standardPrincipal(w1), hash], d);
    const r = simnet.callPublicFn("messaging", "mark-read", [Cl.uint(1)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects self-messaging", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const r = simnet.callPublicFn("messaging", "send-message",
      [Cl.standardPrincipal(d), hash], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});