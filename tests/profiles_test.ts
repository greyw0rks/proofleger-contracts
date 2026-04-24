import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("profiles", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates a profile", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("profiles","create-profile",
      [Cl.stringAscii("greyw0rks"),
       Cl.stringAscii("Web3 founder building on Stacks and Celo"),
       Cl.stringAscii("https://proofleger.vercel.app")],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate profile", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("profiles","create-profile",
      [Cl.stringAscii("name"),Cl.stringAscii("bio"),Cl.stringAscii("url")],d);
    const r = simnet.callPublicFn("profiles","create-profile",
      [Cl.stringAscii("name2"),Cl.stringAscii("bio2"),Cl.stringAscii("url2")],d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("updates an existing profile", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("profiles","create-profile",
      [Cl.stringAscii("old"),Cl.stringAscii("oldbio"),Cl.stringAscii("")],d);
    const r = simnet.callPublicFn("profiles","update-profile",
      [Cl.stringAscii("new"),Cl.stringAscii("newbio"),Cl.stringAscii("https://new.com")],d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("has-profile returns true after creation", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("profiles","create-profile",
      [Cl.stringAscii("check"),Cl.stringAscii("bio"),Cl.stringAscii("")],d);
    const r = simnet.callReadOnlyFn("profiles","has-profile",
      [Cl.standardPrincipal(d)],d);
    expect(r.result).toBeBool(true);
  });
});