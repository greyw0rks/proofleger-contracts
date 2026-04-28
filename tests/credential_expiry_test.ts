import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("credential-expiry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
  it("issuer creates a timed credential", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("credential-expiry", "issue",
      [Cl.standardPrincipal(w2), hash, Cl.uint(99999)], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("is-valid true before expiry", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("credential-expiry", "issue",
      [Cl.standardPrincipal(w2), hash, Cl.uint(99999)], w1);
    const r = simnet.callReadOnlyFn("credential-expiry", "is-valid", [Cl.uint(1)], d);
    expect(r.result).toBeBool(true);
  });
  it("issuer can renew an expiry", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("credential-expiry", "issue",
      [Cl.standardPrincipal(w2), hash, Cl.uint(50000)], w1);
    const r = simnet.callPublicFn("credential-expiry", "renew",
      [Cl.uint(1), Cl.uint(100000)], w1);
    expect(r.result).toBeOk(Cl.uint(100000));
  });
  it("issuer can revoke before expiry", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("credential-expiry", "issue",
      [Cl.standardPrincipal(w2), hash, Cl.uint(99999)], w1);
    const r = simnet.callPublicFn("credential-expiry", "revoke", [Cl.uint(1)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});