import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";

/**
 * Unit tests for achievements.clar
 * Run with: clarinet test
 */

const contractName = "achievements";

describe("achievements: mint-achievement", () => {
  let simnet: any;
  let accounts: Map<string, string>;

  beforeEach(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
  });

  it("mints a soulbound NFT successfully", () => {
    const deployer = accounts.get("deployer")!;
    const recipient = accounts.get("wallet_1")!;
    const result = simnet.callPublicFn(contractName, "mint-achievement", [Cl.standardPrincipal(recipient), Cl.buffer(Buffer.from("a".repeat(64), "hex")), Cl.stringAscii("diploma"), Cl.stringAscii("BSc Computer Science")], deployer);
    expect(result.result).toBeOk(Cl.uint(1));
  });

  it("assigns sequential token IDs", () => {
    const deployer = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    const r1 = simnet.callPublicFn(contractName, "mint-achievement", [Cl.standardPrincipal(w1), Cl.buffer(Buffer.from("a".repeat(64), "hex")), Cl.stringAscii("diploma"), Cl.stringAscii("Degree")], deployer);
    const r2 = simnet.callPublicFn(contractName, "mint-achievement", [Cl.standardPrincipal(w2), Cl.buffer(Buffer.from("b".repeat(64), "hex")), Cl.stringAscii("certificate"), Cl.stringAscii("Cert")], deployer);
    expect(r1.result).toBeOk(Cl.uint(1));
    expect(r2.result).toBeOk(Cl.uint(2));
  });

  it("blocks transfer of soulbound NFT", () => {
    const deployer = accounts.get("deployer")!;
    const w1 = accounts.get("wallet_1")!;
    const w2 = accounts.get("wallet_2")!;
    simnet.callPublicFn(contractName, "mint-achievement", [Cl.standardPrincipal(w1), Cl.buffer(Buffer.from("e".repeat(64), "hex")), Cl.stringAscii("diploma"), Cl.stringAscii("Soulbound")], deployer);
    const result = simnet.callPublicFn(contractName, "transfer", [Cl.uint(1), Cl.standardPrincipal(w1), Cl.standardPrincipal(w2)], w1);
    expect(result.result).toBeErr(Cl.uint(500));
  });
});
