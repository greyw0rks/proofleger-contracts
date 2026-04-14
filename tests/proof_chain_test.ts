import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-chain", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a chain", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("proof-chain", "create-chain",
      [Cl.stringAscii("Fraud Investigation 2026")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("adds a link to the chain", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("proof-chain", "create-chain", [Cl.stringAscii("Evidence Chain")], d);
    const r = simnet.callPublicFn("proof-chain", "add-link",
      [Cl.uint(1), hash, Cl.stringAscii("Initial complaint document")], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("rejects link from non-creator", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("proof-chain", "create-chain", [Cl.stringAscii("Private Chain")], d);
    const r = simnet.callPublicFn("proof-chain", "add-link",
      [Cl.uint(1), hash, Cl.stringAscii("Attempted unauthorized link")], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});