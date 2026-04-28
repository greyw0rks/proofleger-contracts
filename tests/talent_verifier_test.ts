import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("talent-verifier", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("admin attests a builder score", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("talent-verifier", "attest",
      [Cl.standardPrincipal(w1), Cl.uint(82), Cl.stringAscii("passport-abc-123")], d);
    expect(r.result).toBeOk(Cl.uint(82));
  });
  it("is-verified true after attestation", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("talent-verifier", "attest",
      [Cl.standardPrincipal(w1), Cl.uint(75), Cl.stringAscii("pp-xyz")], d);
    const r = simnet.callReadOnlyFn("talent-verifier", "is-verified",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(true);
  });
  it("non-admin cannot attest", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("talent-verifier", "attest",
      [Cl.standardPrincipal(w2), Cl.uint(90), Cl.stringAscii("pp-fake")], w1);
    expect(r.result).toBeErr(Cl.uint(401));
  });
  it("admin revokes an attestation", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("talent-verifier", "attest",
      [Cl.standardPrincipal(w1), Cl.uint(60), Cl.stringAscii("pp-001")], d);
    simnet.callPublicFn("talent-verifier", "revoke", [Cl.standardPrincipal(w1)], d);
    const r = simnet.callReadOnlyFn("talent-verifier", "is-verified",
      [Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(false);
  });
});