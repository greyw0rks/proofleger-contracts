import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("medical-records", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("anchors a medical record", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("medical-records", "anchor-record",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("lab-result")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("patient grants consent", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("medical-records", "anchor-record",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("prescription")], d);
    const r = simnet.callPublicFn("medical-records", "grant-consent", [hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects consent from non-patient", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("medical-records", "anchor-record",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("xray")], d);
    const r = simnet.callPublicFn("medical-records", "grant-consent", [hash], w2);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});