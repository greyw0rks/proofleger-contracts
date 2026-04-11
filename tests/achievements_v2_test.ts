import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("achievements-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("mints NFT with metadata URI", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("diploma"), Cl.stringAscii("BSc CS"),
       Cl.stringAscii("ipfs://QmTest"), Cl.stringAscii("education")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("blocks soulbound transfer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("diploma"), Cl.stringAscii("Degree"),
       Cl.stringAscii(""), Cl.stringAscii("education")], d);
    const r = simnet.callPublicFn("achievements-v2", "transfer",
      [Cl.uint(1), Cl.standardPrincipal(d), Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeErr(Cl.uint(500));
  });
  it("rejects duplicate mint", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("award"), Cl.stringAscii("Winner"),
       Cl.stringAscii(""), Cl.stringAscii("awards")], d);
    const r = simnet.callPublicFn("achievements-v2", "mint",
      [hash, Cl.stringAscii("award"), Cl.stringAscii("Winner"),
       Cl.stringAscii(""), Cl.stringAscii("awards")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});