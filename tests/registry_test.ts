import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers an issuer", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("registry", "register-issuer", [Cl.stringAscii("MIT"), Cl.stringAscii("https://mit.edu")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate registration", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("registry", "register-issuer", [Cl.stringAscii("MIT"), Cl.stringAscii("https://mit.edu")], w1);
    const r = simnet.callPublicFn("registry", "register-issuer", [Cl.stringAscii("MIT2"), Cl.stringAscii("https://x.com")], w1);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("rejects verify from non-owner", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("registry", "register-issuer", [Cl.stringAscii("Uni"), Cl.stringAscii("https://uni.edu")], w1);
    const r = simnet.callPublicFn("registry", "verify-issuer", [Cl.standardPrincipal(w1)], w2);
    expect(r.result).toBeErr(Cl.uint(403));
  });
});