import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("badges", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a badge definition", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("badges", "create-badge", [Cl.stringAscii("top-builder"), Cl.stringAscii("Top Builder"), Cl.stringAscii("Best builders")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("issues a badge to a recipient", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("badges", "create-badge", [Cl.stringAscii("star"), Cl.stringAscii("Star"), Cl.stringAscii("desc")], d);
    const r = simnet.callPublicFn("badges", "issue-badge", [Cl.standardPrincipal(w1), Cl.stringAscii("star")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate badge issuance", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("badges", "create-badge", [Cl.stringAscii("x"), Cl.stringAscii("X"), Cl.stringAscii("d")], d);
    simnet.callPublicFn("badges", "issue-badge", [Cl.standardPrincipal(w1), Cl.stringAscii("x")], d);
    const r = simnet.callPublicFn("badges", "issue-badge", [Cl.standardPrincipal(w1), Cl.stringAscii("x")], d);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});