import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("badges", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin registers a badge type", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("badges", "register-badge",
      [Cl.stringAscii("first-anchor"),
       Cl.stringAscii("First Anchor"),
       Cl.stringAscii("Anchored first document"),
       Cl.uint(10)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("admin awards badge to wallet", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("badges", "register-badge",
      [Cl.stringAscii("century"),
       Cl.stringAscii("Century Mark"),
       Cl.stringAscii("100 proofs"),
       Cl.uint(100)], d);
    const r = simnet.callPublicFn("badges", "award-badge",
      [Cl.standardPrincipal(w1), Cl.stringAscii("century"), Cl.uint(100)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("has-badge returns true after award", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("badges", "register-badge",
      [Cl.stringAscii("pioneer"), Cl.stringAscii("Pioneer"), Cl.stringAscii("desc"), Cl.uint(0)], d);
    simnet.callPublicFn("badges", "award-badge",
      [Cl.standardPrincipal(w1), Cl.stringAscii("pioneer"), Cl.uint(50)], d);
    const r = simnet.callReadOnlyFn("badges", "has-badge",
      [Cl.standardPrincipal(w1), Cl.stringAscii("pioneer")], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects duplicate badge award", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("badges", "register-badge",
      [Cl.stringAscii("dup-test"), Cl.stringAscii("D"), Cl.stringAscii("d"), Cl.uint(0)], d);
    simnet.callPublicFn("badges", "award-badge",
      [Cl.standardPrincipal(w1), Cl.stringAscii("dup-test"), Cl.uint(0)], d);
    const r = simnet.callPublicFn("badges", "award-badge",
      [Cl.standardPrincipal(w1), Cl.stringAscii("dup-test"), Cl.uint(0)], d);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});