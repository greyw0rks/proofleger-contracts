import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("challenges", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a challenge", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("challenges", "create-challenge",
      [Cl.stringAscii("Prove your degree"), Cl.stringAscii("diploma"), Cl.uint(1000000), Cl.uint(144)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("submits a proof for a challenge", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("challenges", "create-challenge",
      [Cl.stringAscii("Challenge 1"), Cl.stringAscii("diploma"), Cl.uint(1000000), Cl.uint(144)], d);
    const r = simnet.callPublicFn("challenges", "submit-proof", [Cl.uint(1), hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate submission", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("challenges", "create-challenge",
      [Cl.stringAscii("Challenge 2"), Cl.stringAscii("diploma"), Cl.uint(1000000), Cl.uint(144)], d);
    simnet.callPublicFn("challenges", "submit-proof", [Cl.uint(1), hash], w1);
    const r = simnet.callPublicFn("challenges", "submit-proof", [Cl.uint(1), hash], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
});