import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("license-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("issues a professional license", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("license-registry", "issue-license",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("medical"), Cl.stringAscii("Nigeria"), Cl.uint(52560)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms is-active-license", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("license-registry", "issue-license",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("engineering"), Cl.stringAscii("US"), Cl.uint(52560)], d);
    const r = simnet.callReadOnlyFn("license-registry", "is-active-license", [hash], d);
    expect(r.result).toBeBool(true);
  });
  it("renews a license (issuing body only)", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("license-registry", "issue-license",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("legal"), Cl.stringAscii("UK"), Cl.uint(52560)], d);
    const r = simnet.callPublicFn("license-registry", "renew-license", [hash, Cl.uint(52560)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects renewal from non-issuer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("license-registry", "issue-license",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("finance"), Cl.stringAscii("CA"), Cl.uint(52560)], d);
    const r = simnet.callPublicFn("license-registry", "renew-license", [hash, Cl.uint(52560)], w1);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});