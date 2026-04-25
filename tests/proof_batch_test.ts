import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-batch", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const h = (c: string) => Cl.buffer(Buffer.from(c.repeat(64), "hex"));
  it("submits a batch of 2 documents", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("proof-batch", "submit-batch-2",
      [h("a"), Cl.stringAscii("Doc A"), Cl.stringAscii("diploma"),
       h("b"), Cl.stringAscii("Doc B"), Cl.stringAscii("certificate"),
       Cl.stringAscii("Class of 2026")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("submits a batch of 3 documents", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("proof-batch", "submit-batch-3",
      [h("a"), Cl.stringAscii("A"), Cl.stringAscii("diploma"),
       h("b"), Cl.stringAscii("B"), Cl.stringAscii("research"),
       h("c"), Cl.stringAscii("C"), Cl.stringAscii("award"),
       Cl.stringAscii("Batch Apr 26")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("reads back a specific hash from a batch", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("proof-batch", "submit-batch-2",
      [h("d"), Cl.stringAscii("D"), Cl.stringAscii("art"),
       h("e"), Cl.stringAscii("E"), Cl.stringAscii("other"),
       Cl.stringAscii("test batch")], d);
    const r = simnet.callReadOnlyFn("proof-batch", "get-batch-hash",
      [Cl.uint(1), Cl.uint(0)], d);
    expect(r.result).toBeSome();
  });
  it("batch-count increments correctly", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("proof-batch", "submit-batch-2",
      [h("f"), Cl.stringAscii("F"), Cl.stringAscii("diploma"),
       h("g"), Cl.stringAscii("G"), Cl.stringAscii("diploma"),
       Cl.stringAscii("memo")], d);
    const r = simnet.callReadOnlyFn("proof-batch", "get-batch-count", [], d);
    expect(r.result).toBeUint(1);
  });
});