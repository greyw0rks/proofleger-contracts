import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("sdk-registry", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  const keyHash = Cl.buffer(Buffer.from("f".repeat(64), "hex"));
  it("developer registers an integration", () => {
    const w1 = accounts.get("wallet_1")!;
    const r = simnet.callPublicFn("sdk-registry", "register",
      [Cl.stringAscii("MyApp"), keyHash, Cl.stringAscii("free")], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("app count increments", () => {
    const w1 = accounts.get("wallet_1")!; const d = accounts.get("deployer")!;
    simnet.callPublicFn("sdk-registry", "register", [Cl.stringAscii("App1"), keyHash, Cl.stringAscii("free")], w1);
    simnet.callPublicFn("sdk-registry", "register", [Cl.stringAscii("App2"), keyHash, Cl.stringAscii("pro")], w1);
    const r = simnet.callReadOnlyFn("sdk-registry", "get-app-count", [], d);
    expect(r.result).toBeUint(2);
  });
  it("record-call increments counter", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("sdk-registry", "register", [Cl.stringAscii("App3"), keyHash, Cl.stringAscii("free")], w1);
    const r = simnet.callPublicFn("sdk-registry", "record-call", [Cl.uint(1)], w1);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("owner can deactivate integration", () => {
    const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("sdk-registry", "register", [Cl.stringAscii("App4"), keyHash, Cl.stringAscii("free")], w1);
    const r = simnet.callPublicFn("sdk-registry", "deactivate", [Cl.uint(1)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
});