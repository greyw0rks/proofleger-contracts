import { describe, it, expect } from "vitest";
import { Clarinet, Tx, Chain, Account, types } from "@hirosystems/clarinet-sdk";
describe("oracle-v2", () => {
  it("authorized feeder submits price", async () => {
    const chain = new Chain(); const [d, f] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-v2","authorize-feeder",[types.principal(f.address)],d.address)]);
    const b = chain.mineBlock([Tx.contractCall("oracle-v2","submit-price",[types.ascii("STX"),types.uint(1500000)],f.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("unauthorized feeder rejected", async () => {
    const chain = new Chain(); const [,s] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("oracle-v2","submit-price",[types.ascii("BTC"),types.uint(60000000000)],s.address)]);
    expect(b.receipts[0].result).toContain("err u100");
  });
  it("aggregates median price", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    const b = chain.mineBlock([Tx.contractCall("oracle-v2","aggregate-price",[types.ascii("STX"),types.list([types.uint(1400000),types.uint(1500000),types.uint(1600000)])],d.address)]);
    expect(b.receipts[0].result).toContain("ok");
  });
  it("returns stale error after 20+ blocks", async () => {
    const chain = new Chain(); const [d] = chain.accounts.values() as Account[];
    chain.mineBlock([Tx.contractCall("oracle-v2","aggregate-price",[types.ascii("CELO"),types.list([types.uint(500000),types.uint(520000)])],d.address)]);
    chain.mineEmptyBlock(25);
    const r = chain.callReadOnlyFn("oracle-v2","get-price",[types.ascii("CELO")],d.address);
    expect(r.result).toContain("err u102");
  });
});