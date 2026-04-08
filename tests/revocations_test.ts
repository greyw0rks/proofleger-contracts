import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("revocations", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("revokes a document hash", () => {
    const deployer = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("revocations", "revoke-document", [hash, Cl.stringAscii("Incorrect data")], deployer);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate revocation", () => {
    const deployer = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("revocations", "revoke-document", [hash, Cl.stringAscii("reason")], deployer);
    const r = simnet.callPublicFn("revocations", "revoke-document", [hash, Cl.stringAscii("reason")], deployer);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("checks is-revoked", () => {
    const deployer = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("revocations", "revoke-document", [hash, Cl.stringAscii("test")], deployer);
    const r = simnet.callReadOnlyFn("revocations", "is-revoked", [hash], deployer);
    expect(r.result).toBeBool(true);
  });
});