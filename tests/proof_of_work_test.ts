import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-of-work", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("logs a work item", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-of-work", "log-work",
      [hash, Cl.stringAscii("Built ProofLedger SDK"), Cl.stringAscii("development"), Cl.uint(8)], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("rejects zero hours", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("proof-of-work", "log-work",
      [hash, Cl.stringAscii("Work"), Cl.stringAscii("dev"), Cl.uint(0)], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("accumulates total hours", () => {
    const d = accounts.get("deployer")!;
    const h1 = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const h2 = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("proof-of-work", "log-work", [h1, Cl.stringAscii("day1"), Cl.stringAscii("dev"), Cl.uint(8)], d);
    simnet.callPublicFn("proof-of-work", "log-work", [h2, Cl.stringAscii("day2"), Cl.stringAscii("dev"), Cl.uint(6)], d);
    const r = simnet.callReadOnlyFn("proof-of-work", "get-work-summary", [Cl.standardPrincipal(d)], d);
    expect(r.result).toBeSome();
  });
});