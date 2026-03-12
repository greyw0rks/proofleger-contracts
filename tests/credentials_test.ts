import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";

/**
 * Unit tests for credentials.clar
 * Run with: clarinet test
 */

const contractName = "credentials";

describe("credentials: issue-credential", () => {
  let simnet: any;
  let accounts: Map<string, string>;

  beforeEach(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
  });

  it("issues a credential successfully", () => {
    const deployer = accounts.get("deployer")!;
    const recipient = accounts.get("wallet_1")!;
    const result = simnet.callPublicFn(contractName, "issue-credential", [Cl.standardPrincipal(recipient), Cl.buffer(Buffer.from("a".repeat(64), "hex")), Cl.stringAscii("diploma"), Cl.stringAscii("MIT")], deployer);
    expect(result.result).toBeOk(Cl.bool(true));
  });

  it("rejects duplicate credential", () => {
    const deployer = accounts.get("deployer")!;
    const recipient = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn(contractName, "issue-credential", [Cl.standardPrincipal(recipient), hash, Cl.stringAscii("certificate"), Cl.stringAscii("Coursera")], deployer);
    const result = simnet.callPublicFn(contractName, "issue-credential", [Cl.standardPrincipal(recipient), hash, Cl.stringAscii("certificate"), Cl.stringAscii("Coursera")], deployer);
    expect(result.result).toBeErr(Cl.uint(101));
  });
});

describe("credentials: revoke-credential", () => {
  let simnet: any;
  let accounts: Map<string, string>;

  beforeEach(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
  });

  it("allows issuer to revoke", () => {
    const deployer = accounts.get("deployer")!;
    const recipient = accounts.get("wallet_1")!;
    const hash = Cl.buffer(Buffer.from("d".repeat(64), "hex"));
    simnet.callPublicFn(contractName, "issue-credential", [Cl.standardPrincipal(recipient), hash, Cl.stringAscii("certificate"), Cl.stringAscii("Test")], deployer);
    const result = simnet.callPublicFn(contractName, "revoke-credential", [Cl.standardPrincipal(recipient), hash], deployer);
    expect(result.result).toBeOk(Cl.bool(true));
  });

  it("rejects revocation from non-issuer", () => {
    const deployer = accounts.get("deployer")!;
    const recipient = accounts.get("wallet_1")!;
    const attacker = accounts.get("wallet_2")!;
    const hash = Cl.buffer(Buffer.from("e".repeat(64), "hex"));
    simnet.callPublicFn(contractName, "issue-credential", [Cl.standardPrincipal(recipient), hash, Cl.stringAscii("diploma"), Cl.stringAscii("Uni")], deployer);
    const result = simnet.callPublicFn(contractName, "revoke-credential", [Cl.standardPrincipal(recipient), hash], attacker);
    expect(result.result).toBeErr(Cl.uint(403));
  });
});
