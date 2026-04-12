import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("identity", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers an identity", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("identity", "register-identity",
      [Cl.stringAscii("did:stacks:SP1SY1..."), Cl.stringAscii("Alice Builder")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate registration", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("identity", "register-identity", [Cl.stringAscii("did:1"), Cl.stringAscii("Alice")], d);
    const r = simnet.callPublicFn("identity", "register-identity", [Cl.stringAscii("did:2"), Cl.stringAscii("Alice2")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("adds a claim to registered identity", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("identity", "register-identity", [Cl.stringAscii("did:stacks:test"), Cl.stringAscii("Bob")], d);
    const r = simnet.callPublicFn("identity", "add-claim",
      [Cl.stringAscii("email"), Cl.stringAscii("bob@example.com"), hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});