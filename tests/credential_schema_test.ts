import { describe, it, expect, beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";
import { Cl } from "@stacks/transactions";
describe("credential-schema", () => {
  let simnet: any; let accounts: Map<string, string>;
  beforeEach(async () => { simnet = await initSimnet(); accounts = simnet.getAccounts(); });
  it("publishes a schema and returns id 1", () => {
    const d = accounts.get("deployer")!;
    const r = simnet.callPublicFn("credential-schema", "publish-schema",
      [Cl.stringAscii("University Diploma"),
       Cl.stringAscii("1.0.0"),
       Cl.stringAscii("{\"fields\":[\"name\",\"degree\",\"year\"]}")], d);
    expect(r.result).toBeOk(Cl.uint(1));
  });
  it("issuer can deprecate their schema", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("credential-schema", "publish-schema",
      [Cl.stringAscii("Old Schema"), Cl.stringAscii("0.9"), Cl.stringAscii("{}")], d);
    const r = simnet.callPublicFn("credential-schema", "deprecate-schema",
      [Cl.uint(1)], d);
    expect(r.result).toBeOk(Cl.bool(true));
  });
  it("non-issuer cannot deprecate", () => {
    const d = accounts.get("deployer")!; const w1 = accounts.get("wallet_1")!;
    simnet.callPublicFn("credential-schema", "publish-schema",
      [Cl.stringAscii("Schema A"), Cl.stringAscii("1.0"), Cl.stringAscii("{}")], d);
    const r = simnet.callPublicFn("credential-schema", "deprecate-schema",
      [Cl.uint(1)], w1);
    expect(r.result).toBeErr(Cl.uint(2));
  });
  it("records usage and increments count", () => {
    const d = accounts.get("deployer")!;
    simnet.callPublicFn("credential-schema", "publish-schema",
      [Cl.stringAscii("Schema B"), Cl.stringAscii("1.0"), Cl.stringAscii("{}")], d);
    simnet.callPublicFn("credential-schema", "record-usage", [Cl.uint(1)], d);
    const r = simnet.callReadOnlyFn("credential-schema", "get-schema-usage",
      [Cl.uint(1)], d);
    expect(r.result).toBeUint(1);
  });
});