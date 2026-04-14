import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("credential-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a credential", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("credential-registry", "register-credential",
      [hash, Cl.stringAscii("diploma"), Cl.standardPrincipal(w1), Cl.stringAscii("BSc CS")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate hash registration", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("credential-registry", "register-credential",
      [hash, Cl.stringAscii("diploma"), Cl.standardPrincipal(w1), Cl.stringAscii("Degree")], d);
    const r = simnet.callPublicFn("credential-registry", "register-credential",
      [hash, Cl.stringAscii("diploma"), Cl.standardPrincipal(w1), Cl.stringAscii("Degree2")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("tracks type count", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const h1 = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const h2 = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("credential-registry", "register-credential",
      [h1, Cl.stringAscii("certificate"), Cl.standardPrincipal(w1), Cl.stringAscii("Cert1")], d);
    simnet.callPublicFn("credential-registry", "register-credential",
      [h2, Cl.stringAscii("certificate"), Cl.standardPrincipal(w1), Cl.stringAscii("Cert2")], d);
    const r = simnet.callReadOnlyFn("credential-registry", "get-type-count",
      [Cl.stringAscii("certificate")], d);
    expect(r.result).toBeUint(2);
  });
});