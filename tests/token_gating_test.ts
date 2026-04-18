import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("token-gating", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("registers a gated resource", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("token-gating", "register-resource",
      [Cl.stringAscii("premium-analytics"),
       Cl.stringAscii("Premium Analytics Dashboard"),
       Cl.stringAscii("nft"),
       Cl.standardPrincipal(d)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("logs resource access", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("token-gating", "register-resource",
      [Cl.stringAscii("course-content"), Cl.stringAscii("Course"),
       Cl.stringAscii("credential"), Cl.standardPrincipal(d)], d);
    const r = simnet.callPublicFn("token-gating", "log-access",
      [Cl.stringAscii("course-content")], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate resource registration", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("token-gating", "register-resource",
      [Cl.stringAscii("unique-res"), Cl.stringAscii("R"), Cl.stringAscii("nft"), Cl.standardPrincipal(d)], d);
    const r = simnet.callPublicFn("token-gating", "register-resource",
      [Cl.stringAscii("unique-res"), Cl.stringAscii("R"), Cl.stringAscii("nft"), Cl.standardPrincipal(d)], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});