import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("certifier", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a certification batch", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("certifier", "create-batch", [Cl.stringAscii("Graduation Class 2026")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("certifies a document in a batch", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("certifier", "create-batch", [Cl.stringAscii("Batch 1")], d);
    const r = simnet.callPublicFn("certifier", "certify", [hash, Cl.uint(1), Cl.stringAscii("diploma")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate certification", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("certifier", "create-batch", [Cl.stringAscii("Batch 2")], d);
    simnet.callPublicFn("certifier", "certify", [hash, Cl.uint(1), Cl.stringAscii("diploma")], d);
    const r = simnet.callPublicFn("certifier", "certify", [hash, Cl.uint(1), Cl.stringAscii("diploma")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});