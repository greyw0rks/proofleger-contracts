import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("escrow", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates an escrow", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("escrow", "create-escrow",
      [Cl.standardPrincipal(w1), Cl.uint(1000000), Cl.none()], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("depositor releases funds", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("escrow", "create-escrow",
      [Cl.standardPrincipal(w1), Cl.uint(500000), Cl.none()], d);
    const r = simnet.callPublicFn("escrow", "release", [Cl.uint(1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("depositor refunds escrow", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("escrow", "create-escrow",
      [Cl.standardPrincipal(w1), Cl.uint(200000), Cl.none()], d);
    const r = simnet.callPublicFn("escrow", "refund", [Cl.uint(1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects release from non-depositor", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("escrow", "create-escrow",
      [Cl.standardPrincipal(w1), Cl.uint(100000), Cl.none()], d);
    const r = simnet.callPublicFn("escrow", "release", [Cl.uint(1)], w2);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});