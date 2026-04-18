import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("data-marketplace", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a data listing", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("data-marketplace", "create-listing",
      [hash, Cl.stringAscii("Stacks On-Chain Analytics Q1 2026"),
       Cl.stringAscii("Transaction analytics dataset"), Cl.uint(5000000)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("rejects zero price listing", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("data-marketplace", "create-listing",
      [hash, Cl.stringAscii("Free Data"), Cl.stringAscii("desc"), Cl.uint(0)], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("checks has-access after purchase", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("data-marketplace", "create-listing",
      [hash, Cl.stringAscii("Dataset"), Cl.stringAscii("desc"), Cl.uint(1000000)], d);
    simnet.callPublicFn("data-marketplace", "purchase-access", [Cl.uint(1)], w1);
    const r = simnet.callReadOnlyFn("data-marketplace", "has-access",
      [Cl.uint(1), Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(true);
  });
});