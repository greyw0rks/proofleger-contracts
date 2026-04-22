import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("attestation-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a typed attestation", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64),"hex"));
    const r = simnet.callPublicFn("attestation-v2","attest",
      [hash,Cl.stringAscii("verified-identity"),
       Cl.stringAscii("KYC verified Q2 2026"),Cl.none(),Cl.uint(5)],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate attestation from same attester", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64),"hex"));
    simnet.callPublicFn("attestation-v2","attest",
      [hash,Cl.stringAscii("academic"),Cl.stringAscii("verified"),Cl.none(),Cl.uint(1)],d);
    const r = simnet.callPublicFn("attestation-v2","attest",
      [hash,Cl.stringAscii("academic"),Cl.stringAscii("again"),Cl.none(),Cl.uint(1)],d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("revokes an attestation", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64),"hex"));
    simnet.callPublicFn("attestation-v2","attest",
      [hash,Cl.stringAscii("employment"),Cl.stringAscii("confirmed"),Cl.none(),Cl.uint(3)],d);
    const r = simnet.callPublicFn("attestation-v2","revoke",[hash],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-valid-attestation false after revocation", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64),"hex"));
    simnet.callPublicFn("attestation-v2","attest",
      [hash,Cl.stringAscii("type"),Cl.stringAscii("meta"),Cl.none(),Cl.uint(1)],d);
    simnet.callPublicFn("attestation-v2","revoke",[hash],d);
    const r = simnet.callReadOnlyFn("attestation-v2","is-valid-attestation",
      [hash,Cl.standardPrincipal(d)],d);
    expect(r.result).toBeBool(false);
  });
});