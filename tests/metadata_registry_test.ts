import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("metadata-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
  it("submitter registers a metadata URI", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("metadata-registry", "register",
      [hash, Cl.stringAscii("ipfs://QmXyz"), Cl.stringAscii("application/json")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("duplicate registration rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("metadata-registry", "register",
      [hash, Cl.stringAscii("ipfs://QmAbc"), Cl.stringAscii("application/json")], w1);
    const r = simnet.callPublicFn("metadata-registry", "register",
      [hash, Cl.stringAscii("ipfs://QmDef"), Cl.stringAscii("application/json")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("owner updates their metadata URI", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("metadata-registry", "register",
      [hash, Cl.stringAscii("ipfs://QmOld"), Cl.stringAscii("application/json")], w1);
    const r = simnet.callPublicFn("metadata-registry", "update-uri",
      [hash, Cl.stringAscii("ipfs://QmNew")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("non-owner cannot update URI", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("metadata-registry", "register",
      [hash, Cl.stringAscii("ipfs://QmOwner"), Cl.stringAscii("application/json")], w1);
    const r = simnet.callPublicFn("metadata-registry", "update-uri",
      [hash, Cl.stringAscii("ipfs://QmHack")], w2);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});