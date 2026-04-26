import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("credential-vault", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("owner stores a credential and gets vault-id 1", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("credential-vault", "store",
      [Cl.stringAscii("ipfs://QmABC"), Cl.stringAscii("diploma")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("owner grants access to grantee", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("credential-vault", "store",
      [Cl.stringAscii("ipfs://QmDEF"), Cl.stringAscii("certificate")], w1);
    const r = simnet.callPublicFn("credential-vault", "grant-access",
      [Cl.uint(1), Cl.standardPrincipal(w2), Cl.uint(0)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("grantee has access after grant", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("credential-vault", "store",
      [Cl.stringAscii("ipfs://QmGHI"), Cl.stringAscii("research")], w1);
    simnet.callPublicFn("credential-vault", "grant-access",
      [Cl.uint(1), Cl.standardPrincipal(w2), Cl.uint(0)], w1);
    const r = simnet.callReadOnlyFn("credential-vault", "has-access",
      [Cl.uint(1), Cl.standardPrincipal(w2)], w1);
    expect(r.result).toBeBool(true);
  });
  it("non-owner cannot grant access", () => {
    const w1 = accounts.get("wallet_1")!; const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn("credential-vault", "store",
      [Cl.stringAscii("ipfs://QmJKL"), Cl.stringAscii("award")], w1);
    const r = simnet.callPublicFn("credential-vault", "grant-access",
      [Cl.uint(1), Cl.standardPrincipal(w2), Cl.uint(0)], w2);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});