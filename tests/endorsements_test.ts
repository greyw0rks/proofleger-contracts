import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("endorsements", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("endorses a document", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64),"hex"));
    const r = simnet.callPublicFn("endorsements","endorse",
      [hash,Cl.stringAscii("Verified by employer"),Cl.uint(3)],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate endorsement", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64),"hex"));
    simnet.callPublicFn("endorsements","endorse",
      [hash,Cl.stringAscii("first"),Cl.uint(1)],d);
    const r = simnet.callPublicFn("endorsements","endorse",
      [hash,Cl.stringAscii("second"),Cl.uint(1)],d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("endorsement count increments", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64),"hex"));
    simnet.callPublicFn("endorsements","endorse",
      [hash,Cl.stringAscii("A"),Cl.uint(2)],d);
    simnet.callPublicFn("endorsements","endorse",
      [hash,Cl.stringAscii("B"),Cl.uint(1)],w1);
    const r = simnet.callReadOnlyFn("endorsements","get-endorsement-count",[hash],d);
    expect(r.result).toBeUint(2);
  });
  it("revokes an endorsement", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64),"hex"));
    simnet.callPublicFn("endorsements","endorse",
      [hash,Cl.stringAscii("comment"),Cl.uint(1)],d);
    const r = simnet.callPublicFn("endorsements","revoke-endorsement",[hash],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});