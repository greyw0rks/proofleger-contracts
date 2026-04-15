import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("publication", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a publication", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const abs = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("publication", "publish",
      [hash, Cl.stringAscii("ZK Proofs on Stacks"), abs,
       Cl.stringAscii("10.1234/test"), Cl.stringAscii("research")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate hash", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const abs = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("publication", "publish",
      [hash, Cl.stringAscii("Paper 1"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    const r = simnet.callPublicFn("publication", "publish",
      [hash, Cl.stringAscii("Paper 2"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("records a citation", () => {
    const d = accounts.get("deployer")!;
    const h1 = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
    const h2 = Cl.buffer(Buffer.from("f".repeat(64), "hex"));
    const abs = Cl.buffer(Buffer.from("1".repeat(64), "hex"));
    simnet.callPublicFn("publication", "publish",
      [h1, Cl.stringAscii("Original"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    simnet.callPublicFn("publication", "publish",
      [h2, Cl.stringAscii("Citing"), abs, Cl.stringAscii(""), Cl.stringAscii("research")], d);
    const r = simnet.callPublicFn("publication", "cite", [h2, h1], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});