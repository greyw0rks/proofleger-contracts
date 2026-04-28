import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("cross-chain-bridge", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
  it("admin registers a relay operator", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("cross-chain-bridge", "register-operator",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Relay Node Alpha")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("registered operator relays a message", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("cross-chain-bridge", "register-operator",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Node A")], d);
    const r = simnet.callPublicFn("cross-chain-bridge", "relay",
      [Cl.stringAscii("stacks"), Cl.stringAscii("celo"), hash], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("unregistered operator relay rejected", () => {
    const w2 = accounts.get("wallet_2")!;
    const r = simnet.callPublicFn("cross-chain-bridge", "relay",
      [Cl.stringAscii("stacks"), Cl.stringAscii("celo"), hash], w2);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("admin confirms a relay message", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("cross-chain-bridge", "register-operator",
      [Cl.standardPrincipal(w1), Cl.stringAscii("Node B")], d);
    simnet.callPublicFn("cross-chain-bridge", "relay",
      [Cl.stringAscii("stacks"), Cl.stringAscii("celo"), hash], w1);
    const r = simnet.callPublicFn("cross-chain-bridge", "confirm",
      [Cl.uint(1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});