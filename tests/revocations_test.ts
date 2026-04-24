import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("revocations", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("revokes a document hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64),"hex"));
    const r = simnet.callPublicFn("revocations","revoke",
      [hash,Cl.stringAscii("Fraudulent credential"),Cl.none()],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-revoked returns true after revocation", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64),"hex"));
    simnet.callPublicFn("revocations","revoke",
      [hash,Cl.stringAscii("Expired"),Cl.none()],d);
    const r = simnet.callReadOnlyFn("revocations","is-revoked",[hash],d);
    expect(r.result).toBeBool(true);
  });
  it("rejects duplicate revocation", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64),"hex"));
    simnet.callPublicFn("revocations","revoke",
      [hash,Cl.stringAscii("first"),Cl.none()],d);
    const r = simnet.callPublicFn("revocations","revoke",
      [hash,Cl.stringAscii("second"),Cl.none()],d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("holder challenges a revocation", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64),"hex"));
    simnet.callPublicFn("revocations","revoke",
      [hash,Cl.stringAscii("Disputed"),Cl.some(Cl.standardPrincipal(w1))],d);
    const r = simnet.callPublicFn("revocations","challenge-revocation",
      [hash,Cl.stringAscii("This credential is valid")],w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});