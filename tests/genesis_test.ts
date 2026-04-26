import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("genesis", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
  it("admin records genesis entry", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("genesis", "record-genesis",
      [hash, Cl.stringAscii("ProofLedger genesis block — Apr 2026")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("is-live false before finalize", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callReadOnlyFn("genesis", "is-live", [], d);
    expect(r.result).toBeBool(false);
  });
  it("finalize sets protocol live", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("genesis", "record-genesis",
      [hash, Cl.stringAscii("genesis")], d);
    simnet.callPublicFn("genesis", "finalize", [], d);
    const r = simnet.callReadOnlyFn("genesis", "is-live", [], d);
    expect(r.result).toBeBool(true);
  });
  it("record-genesis blocked after finalize", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("genesis", "record-genesis", [hash, Cl.stringAscii("first")], d);
    simnet.callPublicFn("genesis", "finalize", [], d);
    const r = simnet.callPublicFn("genesis", "record-genesis",
      [hash, Cl.stringAscii("second — should fail")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});