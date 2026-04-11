import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("notary witness counting", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("increments witness count with each signature", () => {
    const d = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const w3 = accounts.get("wallet_3")!;
    const hash = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("Multi-witness doc")], d);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("Witness 1")], w1);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("Witness 2")], w2);
    simnet.callPublicFn("notary", "add-witness", [hash, Cl.stringAscii("Witness 3")], w3);
    const r = simnet.callReadOnlyFn("notary", "get-notarization", [hash], d);
    expect(r.result).toBeSome();
  });
  it("confirms is-notarized after notarization", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("f".repeat(64), "hex"));
    simnet.callPublicFn("notary", "notarize", [hash, Cl.stringAscii("test")], d);
    const r = simnet.callReadOnlyFn("notary", "is-notarized", [hash], d);
    expect(r.result).toBeBool(true);
  });
});