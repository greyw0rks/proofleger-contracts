import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("insurance-claims", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("files an insurance claim", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("insurance-claims", "file-claim",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("vehicle")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("insurer adjudicates claim", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("insurance-claims", "file-claim",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("property")], d);
    const r = simnet.callPublicFn("insurance-claims", "adjudicate-claim",
      [Cl.uint(1), Cl.stringAscii("approved")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects adjudication from non-insurer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("insurance-claims", "file-claim",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("health")], d);
    const r = simnet.callPublicFn("insurance-claims", "adjudicate-claim",
      [Cl.uint(1), Cl.stringAscii("denied")], w2);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});