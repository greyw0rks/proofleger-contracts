const ADDR = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";
const CONTRACTS = ["proofleger3","credentials","achievements","endorsements","profiles"];
const fs = require("fs");
const path = require("path");
const outDir = "./abis";
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir);
async function exportAbis() {
  for (const name of CONTRACTS) {
    const res = await fetch(`https://api.hiro.so/v2/contracts/interface/${ADDR}/${name}`);
    if (!res.ok) { console.log(`Skipping ${name}: ${res.status}`); continue; }
    const abi = await res.json();
    fs.writeFileSync(path.join(outDir, `${name}.json`), JSON.stringify(abi, null, 2));
    console.log(`Exported ${name}.json`);
  }
}
exportAbis().catch(console.error);