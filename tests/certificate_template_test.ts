import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("certificate-template", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a certificate template", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("certificate-template", "create-template",
      [Cl.stringAscii("Graduation 2026"), Cl.stringAscii("diploma"), Cl.stringAscii("Annual graduation")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("issues a certificate from template", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("certificate-template", "create-template",
      [Cl.stringAscii("Cert Template"), Cl.stringAscii("certificate"), Cl.stringAscii("desc")], d);
    const r = simnet.callPublicFn("certificate-template", "issue-from-template",
      [Cl.uint(1), Cl.standardPrincipal(w1), hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate issuance to same recipient", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const hash2 = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("certificate-template", "create-template",
      [Cl.stringAscii("T2"), Cl.stringAscii("award"), Cl.stringAscii("d")], d);
    simnet.callPublicFn("certificate-template", "issue-from-template",
      [Cl.uint(1), Cl.standardPrincipal(w1), hash], d);
    const r = simnet.callPublicFn("certificate-template", "issue-from-template",
      [Cl.uint(1), Cl.standardPrincipal(w1), hash2], d);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});