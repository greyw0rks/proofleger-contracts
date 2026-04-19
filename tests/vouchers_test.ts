import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("vouchers", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("issues a voucher", () => {
    const d = accounts.get("deployer")!;
    const code = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    const r = simnet.callPublicFn("vouchers", "issue-voucher",
      [code, hash, Cl.stringAscii("diploma")], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("redeems a voucher", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const code = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn("vouchers", "issue-voucher", [code, hash, Cl.stringAscii("award")], d);
    const r = simnet.callPublicFn("vouchers", "redeem-voucher", [code], w1);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("rejects double redemption", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    const code = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
    const hash = Cl.buffer(Buffer.from("f".repeat(64), "hex"));
    simnet.callPublicFn("vouchers", "issue-voucher", [code, hash, Cl.stringAscii("cert")], d);
    simnet.callPublicFn("vouchers", "redeem-voucher", [code], w1);
    const r = simnet.callPublicFn("vouchers", "redeem-voucher", [code], w1);
    expect(r.result).toBeErr(Cl.uint(3));
  });
  it("rejects duplicate issue code", () => {
    const d = accounts.get("deployer")!;
    const code = Cl.buffer(Buffer.from("1".repeat(64), "hex"));
    const hash = Cl.buffer(Buffer.from("2".repeat(64), "hex"));
    simnet.callPublicFn("vouchers", "issue-voucher", [code, hash, Cl.stringAscii("cert")], d);
    const r = simnet.callPublicFn("vouchers", "issue-voucher", [code, hash, Cl.stringAscii("cert")], d);
    expect(r.result).toBeErr(Cl.uint(1));
  });
});