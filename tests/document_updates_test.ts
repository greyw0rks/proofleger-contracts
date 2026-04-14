import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("document-updates", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("supersedes an old document", () => {
    const d = accounts.get("deployer")!;
    const old = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const new_ = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("document-updates", "supersede",
      [old, new_, Cl.stringAscii("Fixed typo in section 3")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("confirms is-superseded", () => {
    const d = accounts.get("deployer")!;
    const old = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const new_ = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("document-updates", "supersede", [old, new_, Cl.stringAscii("Updated")], d);
    const r = simnet.callReadOnlyFn("document-updates", "is-superseded", [old], d);
    expect(r.result).toBeBool(true);
  });
  it("rejects self-supersede", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
    const r = simnet.callPublicFn("document-updates", "supersede",
      [hash, hash, Cl.stringAscii("Self")], d);
    expect(r.result).toBeErr(Cl.uint(2));
  });
});