import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("legal-contracts", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("proposes a contract", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("legal-contracts", "propose-contract",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("service"), Cl.stringAscii("Dev services 2026")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("party B countersigns", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("legal-contracts", "propose-contract",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("nda"), Cl.stringAscii("NDA 2026")], d);
    const r = simnet.callPublicFn("legal-contracts", "countersign", [hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-executed after both signatures", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("legal-contracts", "propose-contract",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("sale"), Cl.stringAscii("Sale agreement")], d);
    simnet.callPublicFn("legal-contracts", "countersign", [hash], w1);
    const r = simnet.callReadOnlyFn("legal-contracts", "is-executed", [hash], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects countersign from non-party-B", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("legal-contracts", "propose-contract",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("lease"), Cl.stringAscii("Lease 2026")], d);
    const r = simnet.callPublicFn("legal-contracts", "countersign", [hash], w2);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});