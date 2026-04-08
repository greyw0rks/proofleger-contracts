const ADDR = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";
const CONTRACTS = ["proofleger3","credentials","achievements"];
async function stats() {
  console.log("ProofLedger Protocol Stats\n" + "=".repeat(40));
  let totalTxs = 0; let totalFees = 0;
  for (const name of CONTRACTS) {
    const res = await fetch(`https://api.hiro.so/extended/v1/address/${ADDR}.${name}/transactions?limit=50`);
    const data = await res.json();
    const txs = (data.results||[]).filter(t => t.tx_status==="success");
    const fees = txs.reduce((s,t) => s+Number(t.fee_rate||0), 0);
    console.log(`${name}: ${data.total||0} txs, ${(fees/1e6).toFixed(4)} STX fees`);
    totalTxs += data.total||0; totalFees += fees;
  }
  console.log("=".repeat(40));
  console.log(`TOTAL: ${totalTxs} txs, ${(totalFees/1e6).toFixed(4)} STX fees`);
}
stats().catch(console.error);