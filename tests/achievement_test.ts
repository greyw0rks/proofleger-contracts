import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("achievement", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin defines an achievement", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("achievement", "define-achievement",
      [Cl.stringAscii("First Anchor"),
       Cl.stringAscii("Anchored your first document"),
       Cl.uint(1), Cl.stringAscii("anchor")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("admin awards achievement to holder", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("achievement", "define-achievement",
      [Cl.stringAscii("Prolific"), Cl.stringAscii("10 anchors"),
       Cl.uint(10), Cl.stringAscii("anchor")], d);
    const r = simnet.callPublicFn("achievement", "award",
      [Cl.standardPrincipal(w1), Cl.uint(1), Cl.uint(10)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("has-achievement true after award", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("achievement", "define-achievement",
      [Cl.stringAscii("Pioneer"), Cl.stringAscii("Early adopter"),
       Cl.uint(1), Cl.stringAscii("anchor")], d);
    simnet.callPublicFn("achievement", "award",
      [Cl.standardPrincipal(w1), Cl.uint(1), Cl.uint(1)], d);
    const r = simnet.callReadOnlyFn("achievement", "has-achievement",
      [Cl.standardPrincipal(w1), Cl.uint(1)], d);
    expect(r.result).toBeBool(true);
  });
  it("duplicate award rejected", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("achievement", "define-achievement",
      [Cl.stringAscii("Dup"), Cl.stringAscii("test"), Cl.uint(1), Cl.stringAscii("anchor")], d);
    simnet.callPublicFn("achievement", "award",
      [Cl.standardPrincipal(w1), Cl.uint(1), Cl.uint(1)], d);
    const r = simnet.callPublicFn("achievement", "award",
      [Cl.standardPrincipal(w1), Cl.uint(1), Cl.uint(2)], d);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});