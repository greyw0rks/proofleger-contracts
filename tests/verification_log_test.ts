import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("verification-log", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
  it("logs a found check and returns id 1", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("verification-log", "log-check",
      [hash, Cl.bool(true), Cl.stringAscii("stacks")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("logs a not-found check", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("verification-log", "log-check",
      [hash, Cl.bool(false), Cl.stringAscii("celo")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("checker count increments", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("verification-log", "log-check",
      [hash, Cl.bool(true), Cl.stringAscii("stacks")], d);
    simnet.callPublicFn("verification-log", "log-check",
      [hash, Cl.bool(true), Cl.stringAscii("stacks")], d);
    const r = simnet.callReadOnlyFn("verification-log", "get-checker-count",
      [Cl.standardPrincipal(d)], d);
    expect(r.result).toBeUint(2);
  });
  it("total-checks is correct", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("verification-log", "log-check",
      [hash, Cl.bool(false), Cl.stringAscii("stacks")], d);
    const r = simnet.callReadOnlyFn("verification-log", "get-total-checks", [], d);
    expect(r.result).toBeUint(1);
  });
});