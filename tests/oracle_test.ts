import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("oracle", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers an oracle (owner only)", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("oracle", "register-oracle", [Cl.standardPrincipal(w1), Cl.stringAscii("Price Feed Oracle")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects register from non-owner", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("oracle", "register-oracle", [Cl.standardPrincipal(w2), Cl.stringAscii("Oracle")], w1);
    expect(r.result).toBeErr(Cl.uint(403));
  });
  it("rejects unregistered oracle feed update", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("oracle", "update-feed", [Cl.stringAscii("STX-USD"), Cl.stringAscii("1.50")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});