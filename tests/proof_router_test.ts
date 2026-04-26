import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-router", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
  it("any caller can route an anchor", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("proof-router", "route-anchor",
      [hash, Cl.stringAscii("proofleger3")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("route count increments", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("proof-router", "route-anchor", [hash, Cl.stringAscii("proofleger3")], d);
    simnet.callPublicFn("proof-router", "route-anchor", [hash, Cl.stringAscii("proofleger3")], d);
    const r = simnet.callReadOnlyFn("proof-router", "get-route-count", [], d);
    expect(r.result).toBeUint(2);
  });
  it("admin sets default target", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("proof-router", "set-default-target",
      [Cl.stringAscii("proofleger4")], d);
    expect(r.result).toBeOk(Cl.stringAscii("proofleger4"));
  });
  it("get-default-target returns seeded value", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("proof-router", "get-default-target", [], d);
    expect(r.result).toBeAscii("proofleger3");
  });
});