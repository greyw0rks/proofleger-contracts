import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("attestation-v2", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("attests with weight", () => {
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(8), Cl.stringAscii("Verified directly")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects weight above 10", () => {
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(11), Cl.stringAscii("Too high")], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
  it("rejects duplicate attestation", () => {
    const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(5), Cl.stringAscii("First")], w1);
    const r = simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(5), Cl.stringAscii("Second")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("returns correct credibility score", () => {
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(8), Cl.stringAscii("Good")], w1);
    simnet.callPublicFn("attestation-v2", "attest-with-weight",
      [hash, Cl.stringAscii("diploma"), Cl.uint(6), Cl.stringAscii("Ok")], w2);
    const r = simnet.callReadOnlyFn("attestation-v2", "get-credibility-score", [hash], w1);
    expect(r.result).toBeUint(7);
  });
});