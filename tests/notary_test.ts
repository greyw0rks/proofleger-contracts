import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("notary", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("notarizes a document hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("Legal agreement 2026")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate notarization", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("doc")], d);
    const r = simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("doc")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("adds a witness signature", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("contract")], d);
    const r = simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("I confirm")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate witness", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("contract")], d);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("I confirm")], w1);
    const r = simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("again")], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});