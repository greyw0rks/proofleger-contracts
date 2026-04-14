import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("expiring-credentials", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("issues an expiring credential", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("expiring-credentials", "issue-expiring",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("license"), Cl.uint(1008)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("is-valid before expiry", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("expiring-credentials", "issue-expiring",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("cert"), Cl.uint(1008)], d);
    const r = simnet.callReadOnlyFn("expiring-credentials", "is-valid", [hash], d);
    expect(r.result).toBeBool(true);
  });
  it("revokes a credential", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("expiring-credentials", "issue-expiring",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("permit"), Cl.uint(1008)], d);
    const r = simnet.callPublicFn("expiring-credentials", "revoke", [hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects revoke from non-issuer", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("expiring-credentials", "issue-expiring",
      [hash, Cl.standardPrincipal(w1), Cl.stringAscii("cert"), Cl.uint(1008)], d);
    const r = simnet.callPublicFn("expiring-credentials", "revoke", [hash], w1);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});