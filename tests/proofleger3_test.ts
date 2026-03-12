import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";

/**
 * Unit tests for proofleger3.clar
 * Run with: clarinet test
 */

const contractName = "proofleger3";

describe("proofleger3: anchor-document", () => {
  let simnet: any;
  let accounts: Map<string, string>;

  beforeEach(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
  });

  it("anchors a document hash successfully", () => {
    const deployer = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("a".repeat(64), "hex"));
    const result = simnet.callPublicFn(contractName, "anchor-document", [hash, Cl.stringAscii("My Diploma"), Cl.stringAscii("diploma")], deployer);
    expect(result.result).toBeOk(Cl.bool(true));
  });

  it("rejects duplicate hash", () => {
    const deployer = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("b".repeat(64), "hex"));
    simnet.callPublicFn(contractName, "anchor-document", [hash, Cl.stringAscii("Doc"), Cl.stringAscii("other")], deployer);
    const result = simnet.callPublicFn(contractName, "anchor-document", [hash, Cl.stringAscii("Doc"), Cl.stringAscii("other")], deployer);
    expect(result.result).toBeErr(Cl.uint(100));
  });
});

describe("proofleger3: verify-document", () => {
  let simnet: any;
  let accounts: Map<string, string>;

  beforeEach(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
  });

  it("returns metadata for existing hash", () => {
    const deployer = accounts.get("deployer")!;
    const hash = Cl.buffer(Buffer.from("c".repeat(64), "hex"));
    simnet.callPublicFn(contractName, "anchor-document", [hash, Cl.stringAscii("Paper"), Cl.stringAscii("research")], deployer);
    const result = simnet.callReadOnlyFn(contractName, "verify-document", [hash], deployer);
    expect(result.result).toBeSome();
  });

  it("returns none for unknown hash", () => {
    const deployer = accounts.get("deployer")!;
    const result = simnet.callReadOnlyFn(contractName, "verify-document", [Cl.buffer(Buffer.from("f".repeat(64), "hex"))], deployer);
    expect(result.result).toBeNone();
  });
});

describe("proofleger3: get-document-count", () => {
  let simnet: any;
  let accounts: Map<string, string>;

  beforeEach(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
  });

  it("starts at zero", () => {
    const deployer = accounts.get("deployer")!;
    const result = simnet.callReadOnlyFn(contractName, "get-document-count", [Cl.standardPrincipal(deployer)], deployer);
    expect(result.result).toBeUint(0);
  });

  it("increments after each anchor", () => {
    const deployer = accounts.get("deployer")!;
    simnet.callPublicFn(contractName, "anchor-document", [Cl.buffer(Buffer.from("e1" + "0".repeat(62), "hex")), Cl.stringAscii("Doc 1"), Cl.stringAscii("other")], deployer);
    simnet.callPublicFn(contractName, "anchor-document", [Cl.buffer(Buffer.from("e2" + "0".repeat(62), "hex")), Cl.stringAscii("Doc 2"), Cl.stringAscii("other")], deployer);
    const result = simnet.callReadOnlyFn(contractName, "get-document-count", [Cl.standardPrincipal(deployer)], deployer);
    expect(result.result).toBeUint(2);
  });
});
