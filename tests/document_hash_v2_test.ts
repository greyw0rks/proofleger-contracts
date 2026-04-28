import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("document-hash-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
  it("submitter anchors with metadata URI", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("document-hash-v2", "anchor",
      [hash, Cl.stringAscii("Research Paper"),
       Cl.stringAscii("research"),
       Cl.stringAscii("ipfs://QmXyzAbc"),
       Cl.uint(0)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("duplicate hash rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("document-hash-v2", "anchor",
      [hash, Cl.stringAscii("Doc"), Cl.stringAscii("other"),
       Cl.stringAscii("ipfs://Qm1"), Cl.uint(0)], w1);
    const r = simnet.callPublicFn("document-hash-v2", "anchor",
      [hash, Cl.stringAscii("Doc2"), Cl.stringAscii("other"),
       Cl.stringAscii("ipfs://Qm2"), Cl.uint(0)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("is-valid true for active un-expired hash", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("document-hash-v2", "anchor",
      [hash, Cl.stringAscii("Cert"), Cl.stringAscii("certificate"),
       Cl.stringAscii("ar://TxABC"), Cl.uint(0)], w1);
    const r = simnet.callReadOnlyFn("document-hash-v2", "is-valid", [hash], d);
    expect(r.result).toBeBool(true);
  });
  it("submitter can revoke their document", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("document-hash-v2", "anchor",
      [hash, Cl.stringAscii("Award"), Cl.stringAscii("award"),
       Cl.stringAscii(""), Cl.uint(0)], w1);
    const r = simnet.callPublicFn("document-hash-v2", "revoke", [hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});