import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("identity", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers an identity", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("identity", "register-identity",
      [Cl.stringAscii("greyw0rks"), Cl.stringAscii("Web3 founder on Stacks and Celo"), hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate identity registration", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("identity", "register-identity",
      [Cl.stringAscii("builder"), Cl.stringAscii("Stacks dev"), hash], d);
    const r = simnet.callPublicFn("identity", "register-identity",
      [Cl.stringAscii("builder2"), Cl.stringAscii("Also dev"), hash], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("adds a claim to identity", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const proof = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("identity", "register-identity",
      [Cl.stringAscii("dev"), Cl.stringAscii("bio"), hash], d);
    const r = simnet.callPublicFn("identity", "add-claim",
      [Cl.stringAscii("education"), proof], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});