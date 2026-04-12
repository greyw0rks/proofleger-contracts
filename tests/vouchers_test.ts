import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("vouchers", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("issues a voucher", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const r = simnet.callPublicFn("vouchers", "issue-voucher",
      [Cl.stringAscii("PROMO2026"), hash, Cl.uint(1000), Cl.uint(144)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects duplicate voucher code", () => {
    const d = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn("vouchers", "issue-voucher", [Cl.stringAscii("DUP"), hash, Cl.uint(100), Cl.uint(144)], d);
    const r = simnet.callPublicFn("vouchers", "issue-voucher", [Cl.stringAscii("DUP"), hash, Cl.uint(100), Cl.uint(144)], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
  it("redeems a valid voucher", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn("vouchers", "issue-voucher", [Cl.stringAscii("REDEEM1"), hash, Cl.uint(100), Cl.uint(144)], d);
    const r = simnet.callPublicFn("vouchers", "redeem-voucher", [Cl.stringAscii("REDEEM1")], w1);
    expect(r.result).toBeOk();
  });
  it("rejects double redemption", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("vouchers", "issue-voucher", [Cl.stringAscii("ONCE"), hash, Cl.uint(100), Cl.uint(144)], d);
    simnet.callPublicFn("vouchers", "redeem-voucher", [Cl.stringAscii("ONCE")], w1);
    const r = simnet.callPublicFn("vouchers", "redeem-voucher", [Cl.stringAscii("ONCE")], w1);
    expect(r.result).toBeErr(Cl.uint(4));
  });
});