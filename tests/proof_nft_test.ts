import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-nft", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("deployer mints a certificate NFT", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-nft", "mint",
      [Cl.standardPrincipal(d), hash,
       Cl.stringAscii("MIT Diploma 2026"), Cl.stringAscii("diploma")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("get-owner returns recipient after mint", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("proof-nft", "mint",
      [Cl.standardPrincipal(w1), hash,
       Cl.stringAscii("Test Cert"), Cl.stringAscii("certificate")], d);
    const r = simnet.callReadOnlyFn("proof-nft", "get-owner",
      [Cl.uint(1)], d);
    expect(r.result).toBeOk();
  });
  it("token metadata stored correctly", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("proof-nft", "mint",
      [Cl.standardPrincipal(d), hash,
       Cl.stringAscii("Research Paper"), Cl.stringAscii("research")], d);
    const r = simnet.callReadOnlyFn("proof-nft", "get-token-metadata",
      [Cl.uint(1)], d);
    expect(r.result).toBeSome();
  });
  it("non-minter cannot mint", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-nft", "mint",
      [Cl.standardPrincipal(d), hash,
       Cl.stringAscii("Fake"), Cl.stringAscii("other")], w1);
    expect(r.result).toBeErr(Cl.uint(402));
  });
});