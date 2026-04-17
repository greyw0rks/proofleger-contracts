import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("real-estate", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("records a property transfer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("real-estate", "record-transfer",
      [hash, Cl.stringAscii("PROP-LAGOS-001"), Cl.standardPrincipal(w1), Cl.stringAscii("deed")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate transfer hash", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("real-estate", "record-transfer",
      [hash, Cl.stringAscii("PROP-ABJ-002"), Cl.standardPrincipal(w1), Cl.stringAscii("deed")], d);
    const r = simnet.callPublicFn("real-estate", "record-transfer",
      [hash, Cl.stringAscii("PROP-ABJ-002"), Cl.standardPrincipal(w1), Cl.stringAscii("deed")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("updates property owner on transfer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("real-estate", "record-transfer",
      [hash, Cl.stringAscii("PROP-PH-003"), Cl.standardPrincipal(w1), Cl.stringAscii("contract")], d);
    const r = simnet.callReadOnlyFn("real-estate", "get-property",
      [Cl.stringAscii("PROP-PH-003")], d);
    expect(r.result).toBeSome();
  });
});