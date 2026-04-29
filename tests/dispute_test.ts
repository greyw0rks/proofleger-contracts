import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("dispute", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
  it("any principal raises a dispute", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("dispute", "raise",
      [hash, Cl.stringAscii("Document title does not match the actual degree")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("admin resolves and upholds dispute", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("dispute", "raise", [hash, Cl.stringAscii("Fraudulent claim")], w1);
    const r = simnet.callPublicFn("dispute", "resolve",
      [Cl.uint(1), Cl.stringAscii("Reviewed and found fraudulent"), Cl.bool(true)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("admin resolves and rejects dispute", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("dispute", "raise", [hash, Cl.stringAscii("Suspicious hash")], w1);
    const r = simnet.callPublicFn("dispute", "resolve",
      [Cl.uint(1), Cl.stringAscii("Document verified legitimate"), Cl.bool(false)], d);
    expect(r.result).toBeOk(Cl.bool(false));
  });
  it("resolving an already-resolved dispute fails", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("dispute", "raise", [hash, Cl.stringAscii("Dispute 1")], w1);
    simnet.callPublicFn("dispute", "resolve",
      [Cl.uint(1), Cl.stringAscii("Resolved"), Cl.bool(false)], d);
    const r = simnet.callPublicFn("dispute", "resolve",
      [Cl.uint(1), Cl.stringAscii("Again"), Cl.bool(true)], d);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});