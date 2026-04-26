import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proofleger-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
  it("submitter anchors a document", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("proofleger-v2", "anchor",
      [hash, Cl.stringAscii("Research Paper 2026"), Cl.stringAscii("research")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("duplicate hash rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proofleger-v2", "anchor",
      [hash, Cl.stringAscii("Doc A"), Cl.stringAscii("other")], w1);
    const r = simnet.callPublicFn("proofleger-v2", "anchor",
      [hash, Cl.stringAscii("Doc A again"), Cl.stringAscii("other")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("owner marks proof verified", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proofleger-v2", "anchor",
      [hash, Cl.stringAscii("Diploma"), Cl.stringAscii("diploma")], w1);
    const r = simnet.callPublicFn("proofleger-v2", "verify", [hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("anchor rejected when paused", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proofleger-v2", "set-paused", [Cl.bool(true)], d);
    const r = simnet.callPublicFn("proofleger-v2", "anchor",
      [hash, Cl.stringAscii("Blocked"), Cl.stringAscii("other")], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});