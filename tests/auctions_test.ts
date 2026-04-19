import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("auctions", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("creates an auction", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("auctions", "create-auction",
      [hash, Cl.uint(500000), Cl.uint(144)], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("places a valid bid", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("auctions", "create-auction", [hash, Cl.uint(100000), Cl.uint(144)], d);
    const r = simnet.callPublicFn("auctions", "place-bid", [Cl.uint(1), Cl.uint(200000)], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects bid below start price", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("auctions", "create-auction", [hash, Cl.uint(1000000), Cl.uint(144)], d);
    const r = simnet.callPublicFn("auctions", "place-bid", [Cl.uint(1), Cl.uint(500)], w1);
    expect(r.result).toBeErr(Cl.uint(5));
  });
});