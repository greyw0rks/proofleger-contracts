import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-bundle", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const h = (c: string) => Cl.buffer(Buffer.from(c.repeat(64), "hex"));
  it("creator creates a bundle", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("proof-bundle", "create-bundle",
      [Cl.stringAscii("Class of 2026 Diplomas")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("creator adds a hash to bundle", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proof-bundle", "create-bundle",
      [Cl.stringAscii("Bundle A")], w1);
    const r = simnet.callPublicFn("proof-bundle", "add-hash",
      [Cl.uint(1), h("a"), Cl.stringAscii("Alice diploma")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("creator seals bundle", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proof-bundle", "create-bundle", [Cl.stringAscii("Bundle B")], w1);
    const r = simnet.callPublicFn("proof-bundle", "seal", [Cl.uint(1)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("add-hash blocked after seal", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proof-bundle", "create-bundle", [Cl.stringAscii("Bundle C")], w1);
    simnet.callPublicFn("proof-bundle", "seal", [Cl.uint(1)], w1);
    const r = simnet.callPublicFn("proof-bundle", "add-hash",
      [Cl.uint(1), h("b"), Cl.stringAscii("Late add")], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});