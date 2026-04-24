import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("achievements", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("mints an achievement NFT", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64),"hex"));
    const r = simnet.callPublicFn("achievements","mint",
      [Cl.standardPrincipal(w1),Cl.stringAscii("first-anchor"),hash],d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("has-achievement returns true after mint", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64),"hex"));
    simnet.callPublicFn("achievements","mint",
      [Cl.standardPrincipal(w1),Cl.stringAscii("century"),hash],d);
    const r = simnet.callReadOnlyFn("achievements","has-achievement",
      [Cl.standardPrincipal(w1),Cl.stringAscii("century")],d);
    expect(r.result).toBeBool(true);
  });
  it("rejects duplicate achievement type for same holder", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64),"hex"));
    simnet.callPublicFn("achievements","mint",
      [Cl.standardPrincipal(w1),Cl.stringAscii("pioneer"),hash],d);
    const r = simnet.callPublicFn("achievements","mint",
      [Cl.standardPrincipal(w1),Cl.stringAscii("pioneer"),hash],d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("transfer is blocked — soulbound", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64),"hex"));
    simnet.callPublicFn("achievements","mint",
      [Cl.standardPrincipal(w1),Cl.stringAscii("attester"),hash],d);
    const r = simnet.callPublicFn("achievements","transfer",
      [Cl.uint(1),Cl.standardPrincipal(w1),Cl.standardPrincipal(w2)],w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
});