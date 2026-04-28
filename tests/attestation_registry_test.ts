import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("attestation-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
  it("attester records an attestation", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("attestation-registry", "attest",
      [hash, Cl.stringAscii("Verified by w1"), Cl.uint(10)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("hash stats increment after attest", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("attestation-registry", "attest",
      [hash, Cl.stringAscii("note"), Cl.uint(5)], w1);
    const r = simnet.callReadOnlyFn("attestation-registry", "get-hash-stats",
      [hash], d);
    expect(r.result).toBeSome();
  });
  it("duplicate attestation from same attester rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("attestation-registry", "attest",
      [hash, Cl.stringAscii("first"), Cl.uint(1)], w1);
    const r = simnet.callPublicFn("attestation-registry", "attest",
      [hash, Cl.stringAscii("second"), Cl.uint(1)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("attester can retract their attestation", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("attestation-registry", "attest",
      [hash, Cl.stringAscii("retractable"), Cl.uint(3)], w1);
    const r = simnet.callPublicFn("attestation-registry", "retract", [hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});