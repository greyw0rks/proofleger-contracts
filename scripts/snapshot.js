const ADDR = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";
const fs = require("fs");
async function snapshot() {
  console.log("Creating ProofLedger state snapshot...");
  const snap = { timestamp: new Date().toISOString(), contracts: {} };
  const contracts = ["proofleger3","credentials","achievements"];
  for (const name of contracts) {
    const res = await fetch(`https://api.hiro.so/extended/v1/address/${ADDR}.${name}/transactions?limit=50`);
    const data = await res.json();
    snap.contracts[name] = { total: data.total||0, recent: (data.results||[]).slice(0,10).map(t=>({ txid:t.tx_id, fn:t.contract_call?.function_name, block:t.block_height, sender:t.sender_address })) };
  }
  const file = `snapshot-${Date.now()}.json`;
  fs.writeFileSync(file, JSON.stringify(snap, null, 2));
  console.log(`Saved: ${file}`);
}
snapshot().catch(console.error);