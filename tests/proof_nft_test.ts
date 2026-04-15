import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-nft", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("mints a transferable proof NFT", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Research Paper 2026"), Cl.stringAscii("research")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("rejects duplicate mint for same hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Diploma"), Cl.stringAscii("diploma")], d);
    const r = simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Diploma 2"), Cl.stringAscii("diploma")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("transfers NFT to another wallet", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("proof-nft", "mint",
      [hash, Cl.stringAscii("Art NFT"), Cl.stringAscii("art")], d);
    const r = simnet.callPublicFn("proof-nft", "transfer",
      [Cl.uint(1), Cl.standardPrincipal(d), Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});