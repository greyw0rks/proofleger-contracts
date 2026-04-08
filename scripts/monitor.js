const ADDR = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";
const CONTRACTS = ["proofleger3", "credentials", "achievements"];
let lastBlock = 0;
async function poll() {
  for (const name of CONTRACTS) {
    const res = await fetch(`https://api.hiro.so/extended/v1/address/${ADDR}.${name}/transactions?limit=5`);
    const data = await res.json();
    const newTxs = (data.results||[]).filter(t => t.block_height > lastBlock && t.tx_status === "success");
    for (const tx of newTxs) {
      console.log(`[${new Date().toISOString()}] ${name}:${tx.contract_call?.function_name} by ${tx.sender_address?.slice(0,12)}... block#${tx.block_height}`);
      if (tx.block_height > lastBlock) lastBlock = tx.block_height;
    }
  }
}
async function main() {
  console.log("ProofLedger Monitor started. Polling every 60s...\n");
  await poll();
  setInterval(poll, 60_000);
}
main().catch(console.error);