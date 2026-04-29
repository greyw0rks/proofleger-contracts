import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("expiry-manager", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
  it("owner registers a future expiry", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("expiry-manager", "register",
      [hash, Cl.uint(99999)], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("is-expired false before expiry block", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("expiry-manager", "register", [hash, Cl.uint(99999)], w1);
    const r = simnet.callReadOnlyFn("expiry-manager", "is-expired", [Cl.uint(1)], d);
    expect(r.result).toBeBool(false);
  });
  it("flag-expired blocked before expiry block", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("expiry-manager", "register", [hash, Cl.uint(99999)], w1);
    const r = simnet.callPublicFn("expiry-manager", "flag-expired", [Cl.uint(1)], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
  it("register with past expiry blocked", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("expiry-manager", "register",
      [hash, Cl.uint(1)], w1); // block 1 is always in the past in simnet
    expect(r.result).toBeErr(Cl.uint(1));
  });
});