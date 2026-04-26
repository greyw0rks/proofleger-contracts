import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-mirror", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
  const celoTx = Cl.stringAscii("0x" + "a".repeat(64));
  it("agent records a cross-chain mirror", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("proof-mirror", "record-mirror",
      [hash, celoTx, Cl.uint(42500)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-mirrored true after recording", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("proof-mirror", "record-mirror", [hash, celoTx, Cl.uint(42500)], w1);
    const r = simnet.callReadOnlyFn("proof-mirror", "is-mirrored", [hash], d);
    expect(r.result).toBeBool(true);
  });
  it("duplicate mirror rejected", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proof-mirror", "record-mirror", [hash, celoTx, Cl.uint(42500)], w1);
    const r = simnet.callPublicFn("proof-mirror", "record-mirror",
      [hash, celoTx, Cl.uint(42501)], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("admin confirms a mirror", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("proof-mirror", "record-mirror", [hash, celoTx, Cl.uint(42500)], w1);
    const r = simnet.callPublicFn("proof-mirror", "confirm-mirror", [hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});