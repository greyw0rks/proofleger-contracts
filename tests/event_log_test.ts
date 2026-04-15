import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("event-log", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("logs an event", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("document.anchored"), Cl.none(), Cl.none(),
       Cl.stringAscii("Document anchored by bot")], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("retrieves a logged event", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("wallet.connected"), Cl.none(), Cl.none(), Cl.stringAscii("data")], d);
    const r = simnet.callReadOnlyFn("event-log", "get-event", [Cl.uint(0)], d);
    expect(r.result).toBeSome();
  });
  it("increments event count", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("event.1"), Cl.none(), Cl.none(), Cl.stringAscii("")], d);
    simnet.callPublicFn("event-log", "log-event",
      [Cl.stringAscii("event.2"), Cl.none(), Cl.none(), Cl.stringAscii("")], d);
    const r = simnet.callReadOnlyFn("event-log", "get-event-count", [], d);
    expect(r.result).toBeUint(2);
  });
});