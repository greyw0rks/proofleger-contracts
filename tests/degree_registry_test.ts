import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("degree-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("issues a degree", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("degree-registry", "issue-degree",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("Bachelor"), Cl.stringAscii("Computer Science")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate hash", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("degree-registry", "issue-degree",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("Bachelor"), Cl.stringAscii("CS")], d);
    const r = simnet.callPublicFn("degree-registry", "issue-degree",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("Master"), Cl.stringAscii("CS")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("tracks institution degree count", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const h1 = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const h2 = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("degree-registry", "issue-degree",
      [h1, Cl.standardPrincipal(w1), Cl.stringAscii("Bachelor"), Cl.stringAscii("CS")], d);
    simnet.callPublicFn("degree-registry", "issue-degree",
      [h2, Cl.standardPrincipal(w2), Cl.stringAscii("Master"), Cl.stringAscii("ML")], d);
    const r = simnet.callReadOnlyFn("degree-registry", "get-institution-count",
      [Cl.standardPrincipal(d)], d);
    expect(r.result).toBeUint(2);
  });
});