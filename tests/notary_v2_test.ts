import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("notary-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
  it("notary creates a notarization", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("notary-v2", "notarize",
      [hash, Cl.stringAscii("Partnership Agreement 2026")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("witness can co-sign", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("notary-v2", "notarize",
      [hash, Cl.stringAscii("Contract")], w1);
    const r = simnet.callPublicFn("notary-v2", "co-sign", [Cl.uint(1)], w2);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("notary can seal after witness signs", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("notary-v2", "notarize", [hash, Cl.stringAscii("Doc")], w1);
    simnet.callPublicFn("notary-v2", "co-sign", [Cl.uint(1)], w2);
    const r = simnet.callPublicFn("notary-v2", "seal", [Cl.uint(1)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("notary cannot be their own witness", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("notary-v2", "notarize", [hash, Cl.stringAscii("Self")], w1);
    const r = simnet.callPublicFn("notary-v2", "co-sign", [Cl.uint(1)], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});