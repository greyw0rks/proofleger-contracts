import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("collections", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a collection", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("collections", "create-collection", [Cl.stringAscii("Research"), Cl.stringAscii("My papers")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("adds a document to a collection", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("collections", "create-collection", [Cl.stringAscii("Certs"), Cl.stringAscii("desc")], d);
    const r = simnet.callPublicFn("collections", "add-to-collection", [Cl.stringAscii("Certs"), hash], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate collection name", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("collections", "create-collection", [Cl.stringAscii("Dup"), Cl.stringAscii("d")], d);
    const r = simnet.callPublicFn("collections", "create-collection", [Cl.stringAscii("Dup"), Cl.stringAscii("d")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});