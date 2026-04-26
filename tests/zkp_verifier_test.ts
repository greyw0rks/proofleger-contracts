import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("zkp-verifier", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
  it("any verifier can attest a valid ZKP", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("zkp-verifier", "attest",
      [hash, Cl.stringAscii("groth16"),
       Cl.stringAscii("{\"degree\":\"CS\",\"year\":\"2026\"}"),
       Cl.bool(true)], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("invalid proof can also be recorded", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("zkp-verifier", "attest",
      [hash, Cl.stringAscii("plonk"),
       Cl.stringAscii("{}"), Cl.bool(false)], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("verifier count increments correctly", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("zkp-verifier", "attest",
      [hash, Cl.stringAscii("stark"), Cl.stringAscii("{}"), Cl.bool(true)], d);
    simnet.callPublicFn("zkp-verifier", "attest",
      [hash, Cl.stringAscii("stark"), Cl.stringAscii("{}"), Cl.bool(true)], d);
    const r = simnet.callReadOnlyFn("zkp-verifier", "get-verifier-count",
      [Cl.standardPrincipal(d)], d);
    expect(r.result).toBeUint(2);
  });
  it("total attestations is correct", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("zkp-verifier", "attest",
      [hash, Cl.stringAscii("groth16"), Cl.stringAscii("{}"), Cl.bool(true)], d);
    const r = simnet.callReadOnlyFn("zkp-verifier", "get-total-attestations", [], d);
    expect(r.result).toBeUint(1);
  });
});