import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("multisig", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a 2-of-3 multisig wallet", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("multisig", "create-multisig",
      [Cl.list([Cl.standardPrincipal(d),Cl.standardPrincipal(w1),Cl.standardPrincipal(w2)]),
       Cl.uint(2)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("owner submits a proposal", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("multisig","create-multisig",
      [Cl.list([Cl.standardPrincipal(d),Cl.standardPrincipal(w1)]),Cl.uint(2)],d);
    const r = simnet.callPublicFn("multisig","propose",
      [Cl.uint(1),Cl.stringAscii("Deploy proofleger-v2")],d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("approval count increments correctly", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("multisig","create-multisig",
      [Cl.list([Cl.standardPrincipal(d),Cl.standardPrincipal(w1)]),Cl.uint(2)],d);
    simnet.callPublicFn("multisig","propose",[Cl.uint(1),Cl.stringAscii("action")],d);
    const r = simnet.callPublicFn("multisig","approve",[Cl.uint(1),Cl.uint(1)],d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("is-approved true after threshold met", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("multisig","create-multisig",
      [Cl.list([Cl.standardPrincipal(d),Cl.standardPrincipal(w1)]),Cl.uint(1)],d);
    simnet.callPublicFn("multisig","propose",[Cl.uint(1),Cl.stringAscii("go")],d);
    simnet.callPublicFn("multisig","approve",[Cl.uint(1),Cl.uint(1)],d);
    const r = simnet.callReadOnlyFn("multisig","is-approved",
      [Cl.uint(1),Cl.uint(1)],d);
    expect(r.result).toBeBool(true);
  });
});