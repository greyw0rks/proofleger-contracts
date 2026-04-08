const ADDR = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";
const CONTRACTS = ["proofleger3","credentials","achievements","endorsements","profiles","revocations","reputation","collections","badges","registry","governance","subscriptions","messaging","timestamps","oracle"];
async function verify() {
  console.log("Verifying ProofLedger contracts on mainnet...\n");
  let ok = 0, fail = 0;
  for (const name of CONTRACTS) {
    try {
      const res = await fetch(`https://api.hiro.so/v2/contracts/interface/${ADDR}/${name}`);
      if (res.ok) { const d = await res.json(); console.log(`✓ ${name}: ${d.functions?.length||0} functions`); ok++; }
      else { console.log(`✗ ${name}: HTTP ${res.status}`); fail++; }
    } catch(e) { console.log(`✗ ${name}: ${e.message}`); fail++; }
  }
  console.log(`\n${ok} deployed, ${fail} missing`);
}
verify().catch(console.error);