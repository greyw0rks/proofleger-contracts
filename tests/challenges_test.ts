import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("challenges", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a challenge", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("challenges", "create-challenge",
      [Cl.stringAscii("Build a Clarity DApp"), Cl.stringAscii("development"),
       Cl.uint(1000), Cl.uint(0)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("submits a proof to a challenge", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("challenges", "create-challenge",
      [Cl.stringAscii("Write tests"), Cl.stringAscii("testing"), Cl.uint(5000), Cl.uint(0)], d);
    const r = simnet.callPublicFn("challenges", "submit-proof", [Cl.uint(1), hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate submission from same wallet", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("challenges", "create-challenge",
      [Cl.stringAscii("Deploy contract"), Cl.stringAscii("deployment"), Cl.uint(5000), Cl.uint(0)], d);
    simnet.callPublicFn("challenges", "submit-proof", [Cl.uint(1), hash], w1);
    const r = simnet.callPublicFn("challenges", "submit-proof", [Cl.uint(1), hash], w1);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});