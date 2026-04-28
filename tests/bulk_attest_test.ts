import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("bulk-attest", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const h = (c: string) => Cl.buffer(Buffer.from(c.repeat(64), "hex"));
  it("attests 2 hashes in one call", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("bulk-attest", "attest-2",
      [h("a"), Cl.stringAscii("note A"),
       h("b"), Cl.stringAscii("note B"),
       Cl.stringAscii("batch Q1")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("attests 3 hashes in one call", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("bulk-attest", "attest-3",
      [h("c"), Cl.stringAscii("C"), h("d"), Cl.stringAscii("D"),
       h("e"), Cl.stringAscii("E"), Cl.stringAscii("batch Q2")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("reads back hash at specific index", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("bulk-attest", "attest-2",
      [h("f"), Cl.stringAscii("F"), h("g"), Cl.stringAscii("G"),
       Cl.stringAscii("test")], w1);
    const r = simnet.callReadOnlyFn("bulk-attest", "get-hash",
      [Cl.uint(1), Cl.uint(1)], w1);
    expect(r.result).toBeSome();
  });
  it("batch count tracks total submissions", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("bulk-attest", "attest-2",
      [h("h"), Cl.stringAscii("H"), h("i"), Cl.stringAscii("I"),
       Cl.stringAscii("m1")], w1);
    const r = simnet.callReadOnlyFn("bulk-attest", "get-batch-count", [], w1);
    expect(r.result).toBeUint(1);
  });
});