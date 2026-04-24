import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("collections", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a collection", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("collections","create-collection",
      [Cl.stringAscii("Academic Credentials"),
       Cl.stringAscii("All my university documents"),
       Cl.bool(true)],d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("adds a document to collection", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64),"hex"));
    simnet.callPublicFn("collections","create-collection",
      [Cl.stringAscii("Work Proofs"),Cl.stringAscii("Employment history"),Cl.bool(true)],d);
    const r = simnet.callPublicFn("collections","add-doc",[Cl.uint(1),hash],d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("rejects duplicate doc in same collection", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64),"hex"));
    simnet.callPublicFn("collections","create-collection",
      [Cl.stringAscii("C"),Cl.stringAscii("D"),Cl.bool(true)],d);
    simnet.callPublicFn("collections","add-doc",[Cl.uint(1),hash],d);
    const r = simnet.callPublicFn("collections","add-doc",[Cl.uint(1),hash],d);
    expect(r.result).toBeErr(Cl.uint(3));
  });
  it("non-owner cannot add to collection", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64),"hex"));
    simnet.callPublicFn("collections","create-collection",
      [Cl.stringAscii("Private"),Cl.stringAscii("Private collection"),Cl.bool(false)],d);
    const r = simnet.callPublicFn("collections","add-doc",[Cl.uint(1),hash],w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});