import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("document-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = () => Cl.buffer(Buffer.from("a".repeat(64), "hex"));
  it("registers a document", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("document-registry", "register",
      [hash(), Cl.stringAscii("MIT Diploma 2026"), Cl.stringAscii("diploma")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate hash registration", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("document-registry", "register",
      [hash(), Cl.stringAscii("doc"), Cl.stringAscii("other")], d);
    const r = simnet.callPublicFn("document-registry", "register",
      [hash(), Cl.stringAscii("doc2"), Cl.stringAscii("other")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("issuer can revoke their document", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("document-registry", "register",
      [hash(), Cl.stringAscii("cert"), Cl.stringAscii("certificate")], d);
    const r = simnet.callPublicFn("document-registry", "revoke", [hash()], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("non-issuer cannot revoke", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("document-registry", "register",
      [hash(), Cl.stringAscii("art"), Cl.stringAscii("art")], d);
    const r = simnet.callPublicFn("document-registry", "revoke", [hash()], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});