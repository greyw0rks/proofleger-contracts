import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("vault-access-log", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("any principal logs a grant event", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("vault-access-log", "log-event",
      [Cl.uint(1), Cl.standardPrincipal(w2), Cl.stringAscii("grant")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("event count increments", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("vault-access-log", "log-event",
      [Cl.uint(1), Cl.standardPrincipal(w1), Cl.stringAscii("view")], w1);
    simnet.callPublicFn("vault-access-log", "log-event",
      [Cl.uint(1), Cl.standardPrincipal(w1), Cl.stringAscii("view")], w1);
    const r = simnet.callReadOnlyFn("vault-access-log", "get-event-count", [], d);
    expect(r.result).toBeUint(2);
  });
  it("vault event count tracks per-vault", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("vault-access-log", "log-event",
      [Cl.uint(7), Cl.standardPrincipal(w1), Cl.stringAscii("revoke")], w1);
    const r = simnet.callReadOnlyFn("vault-access-log", "get-vault-event-count",
      [Cl.uint(7)], d);
    expect(r.result).toBeUint(1);
  });
  it("get-event returns stored event", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("vault-access-log", "log-event",
      [Cl.uint(2), Cl.standardPrincipal(w1), Cl.stringAscii("grant")], w1);
    const r = simnet.callReadOnlyFn("vault-access-log", "get-event", [Cl.uint(1)], d);
    expect(r.result).toBeSome();
  });
});