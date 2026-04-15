import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("skill-tree", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("adds a skill with proof", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("skill-tree", "add-skill",
      [Cl.stringAscii("Clarity Smart Contracts"), hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate skill", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("TypeScript"), hash], d);
    const r = simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("TypeScript"), hash], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("endorses a skill", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("Solidity"), hash], d);
    const r = simnet.callPublicFn("skill-tree", "endorse-skill",
      [Cl.standardPrincipal(d), Cl.stringAscii("Solidity")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects self-endorsement", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("skill-tree", "add-skill", [Cl.stringAscii("Python"), hash], d);
    const r = simnet.callPublicFn("skill-tree", "endorse-skill",
      [Cl.standardPrincipal(d), Cl.stringAscii("Python")], d);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});