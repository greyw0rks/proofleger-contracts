import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("notary", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("initiates a notarization", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("notary", "initiate-notarization",
      [hash, Cl.stringAscii("Contract Agreement 2026")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("witness signs the notarization", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("notary", "initiate-notarization",
      [hash, Cl.stringAscii("Service Agreement")], d);
    const r = simnet.callPublicFn("notary", "witness-sign",
      [hash, Cl.stringAscii("I confirm this document")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects self-witnessing by initiator", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("notary", "initiate-notarization",
      [hash, Cl.stringAscii("NDA")], d);
    const r = simnet.callPublicFn("notary", "witness-sign",
      [hash, Cl.stringAscii("self attest")], d);
    expect(r.result).toBeErr(Cl.uint(4));
  });
  it("finalizes after witness signs", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("notary", "initiate-notarization",
      [hash, Cl.stringAscii("Final doc")], d);
    simnet.callPublicFn("notary", "witness-sign",
      [hash, Cl.stringAscii("confirmed")], w1);
    const r = simnet.callPublicFn("notary", "finalize", [hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});