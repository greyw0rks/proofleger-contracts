import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("issuer-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("principal self-registers as issuer", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("issuer-registry", "self-register",
      [Cl.stringAscii("MIT"), Cl.stringAscii("https://mit.edu"),
       Cl.stringAscii("university")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("admin verifies an issuer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("issuer-registry", "self-register",
      [Cl.stringAscii("Stanford"), Cl.stringAscii("https://stanford.edu"),
       Cl.stringAscii("university")], w1);
    const r = simnet.callPublicFn("issuer-registry", "verify-issuer",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-verified-issuer true after verification", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("issuer-registry", "self-register",
      [Cl.stringAscii("Harvard"), Cl.stringAscii("https://harvard.edu"),
       Cl.stringAscii("university")], w1);
    simnet.callPublicFn("issuer-registry", "verify-issuer",
      [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("issuer-registry", "is-verified-issuer",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(true);
  });
  it("duplicate self-register rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("issuer-registry", "self-register",
      [Cl.stringAscii("Org A"), Cl.stringAscii("https://a.org"),
       Cl.stringAscii("other")], w1);
    const r = simnet.callPublicFn("issuer-registry", "self-register",
      [Cl.stringAscii("Org A again"), Cl.stringAscii("https://a.org"),
       Cl.stringAscii("other")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});