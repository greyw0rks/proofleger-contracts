import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("cross-chain-bridge", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("records a bridge event", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("cross-chain-bridge", "record-bridge",
      [hash, Cl.stringAscii("stacks"), Cl.stringAscii("celo"),
       Cl.stringAscii("0x251B3302c0CcB1cFBeb0cda3dE06C2D312a41735")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms a bridge record", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("cross-chain-bridge", "record-bridge",
      [hash, Cl.stringAscii("stacks"), Cl.stringAscii("celo"), Cl.stringAscii("0x123")], d);
    const r = simnet.callPublicFn("cross-chain-bridge", "confirm-bridge",
      [hash, Cl.stringAscii("stacks")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate bridge record", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("cross-chain-bridge", "record-bridge",
      [hash, Cl.stringAscii("stacks"), Cl.stringAscii("celo"), Cl.stringAscii("0x456")], d);
    const r = simnet.callPublicFn("cross-chain-bridge", "record-bridge",
      [hash, Cl.stringAscii("stacks"), Cl.stringAscii("celo"), Cl.stringAscii("0x456")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});