import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("work-history", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("adds an employment record", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("work-history", "add-employment",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Senior Developer"), hash], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("employer verifies employment", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("work-history", "add-employment",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Engineer"), hash], d);
    const r = simnet.callPublicFn("work-history", "verify-employment",
      [Cl.standardPrincipal(d), Cl.uint(0)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects verification from wrong employer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("work-history", "add-employment",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Analyst"), hash], d);
    const r = simnet.callPublicFn("work-history", "verify-employment",
      [Cl.standardPrincipal(d), Cl.uint(0)], w2);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});