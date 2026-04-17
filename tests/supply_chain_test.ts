import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("supply-chain", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a shipment", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("supply-chain", "create-shipment",
      [Cl.stringAscii("SHIP-2026-001"), Cl.stringAscii("Lagos"), Cl.stringAscii("London")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("adds a step to shipment", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    simnet.callPublicFn("supply-chain", "create-shipment",
      [Cl.stringAscii("SHIP-2026-002"), Cl.stringAscii("Accra"), Cl.stringAscii("Berlin")], d);
    const r = simnet.callPublicFn("supply-chain", "add-step",
      [Cl.stringAscii("SHIP-2026-002"), Cl.stringAscii("Customs cleared"), hash], d);
    expect(r.result).toBeOk(Cl.uint(0));
  });
  it("rejects duplicate shipment ID", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("supply-chain", "create-shipment",
      [Cl.stringAscii("SHIP-DUP"), Cl.stringAscii("A"), Cl.stringAscii("B")], d);
    const r = simnet.callPublicFn("supply-chain", "create-shipment",
      [Cl.stringAscii("SHIP-DUP"), Cl.stringAscii("A"), Cl.stringAscii("B")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});