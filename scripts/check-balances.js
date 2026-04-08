const AGENT = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";
const MIN_STX = 10;
async function check() {
  const res = await fetch(`https://api.hiro.so/v2/accounts/${AGENT}?proof=0`);
  const data = await res.json();
  const stx = Number(data.balance) / 1e6;
  console.log(`Agent wallet: ${AGENT}`);
  console.log(`Balance: ${stx.toFixed(4)} STX`);
  if (stx < MIN_STX) {
    console.log(`WARNING: Low balance. Minimum recommended: ${MIN_STX} STX`);
    process.exit(1);
  } else {
    console.log(`OK: Balance sufficient for operations`);
  }
}
check().catch(console.error);