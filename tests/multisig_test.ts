import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("multisig", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a 2-of-3 config", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(2), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1), Cl.standardPrincipal(w2)])], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("approves a document hash", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(2), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1), Cl.standardPrincipal(w2)])], d);
    const r = simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    expect(r.result).toBeOk(Cl.bool(false));
  });
  it("marks approved when threshold met", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(2), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1)])], d);
    simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    const r = simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate approval", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("multisig", "create-config",
      [Cl.uint(1), Cl.list([Cl.standardPrincipal(d), Cl.standardPrincipal(w1)])], d);
    simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    const r = simnet.callPublicFn("multisig", "approve", [Cl.uint(1), hash], d);
    expect(r.result).toBeErr(Cl.uint(5));
  });
});