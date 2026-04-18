import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("proof-of-attendance", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates an event", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("proof-of-attendance", "create-event",
      [Cl.stringAscii("STACKS-CONF-2026"), Cl.stringAscii("Stacks Summit 2026"),
       Cl.stringAscii("Lagos, Nigeria"), Cl.uint(500)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("attendee checks in", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("proof-of-attendance", "create-event",
      [Cl.stringAscii("EVT-001"), Cl.stringAscii("Workshop"), Cl.stringAscii("Online"), Cl.uint(100)], d);
    const r = simnet.callPublicFn("proof-of-attendance", "check-in",
      [Cl.stringAscii("EVT-001"), hash], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate check-in", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("proof-of-attendance", "create-event",
      [Cl.stringAscii("EVT-002"), Cl.stringAscii("Meetup"), Cl.stringAscii("Abuja"), Cl.uint(50)], d);
    simnet.callPublicFn("proof-of-attendance", "check-in", [Cl.stringAscii("EVT-002"), hash], w1);
    const r = simnet.callPublicFn("proof-of-attendance", "check-in",
      [Cl.stringAscii("EVT-002"), hash], w1);
    expect(r.result).toBeErr(Cl.uint(4));
  });
  it("confirms attended status", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("proof-of-attendance", "create-event",
      [Cl.stringAscii("EVT-003"), Cl.stringAscii("Hackathon"), Cl.stringAscii("Virtual"), Cl.uint(200)], d);
    simnet.callPublicFn("proof-of-attendance", "check-in", [Cl.stringAscii("EVT-003"), hash], w1);
    const r = simnet.callReadOnlyFn("proof-of-attendance", "attended",
      [Cl.stringAscii("EVT-003"), Cl.standardPrincipal(w1)], d);
    expect(r.result).toBeBool(true);
  });
});