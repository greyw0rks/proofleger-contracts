import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("timestamps", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("anchors a timestamp for an identifier", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("timestamps", "anchor-timestamp", [Cl.stringAscii("https://example.com/article-1")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate timestamp", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("timestamps", "anchor-timestamp", [Cl.stringAscii("myid-123")], d);
    const r = simnet.callPublicFn("timestamps", "anchor-timestamp", [Cl.stringAscii("myid-123")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("confirms was-anchored", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("timestamps", "anchor-timestamp", [Cl.stringAscii("checkthis")], d);
    const r = simnet.callReadOnlyFn("timestamps", "was-anchored", [Cl.stringAscii("checkthis")], d);
    expect(r.result).toBeBool(true);
  });
});