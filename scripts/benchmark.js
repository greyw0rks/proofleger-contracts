const ADDR = "SP1SY1E599GN04XRD2DQBKV7E62HYBJR2CT9S5QKK";
const HASH = "a".repeat(64);
async function benchmark(n = 10) {
  console.log(`Benchmarking ${n} verify-document calls...`);
  const times = [];
  for (let i = 0; i < n; i++) {
    const start = Date.now();
    await fetch(`https://api.hiro.so/v2/contracts/call-read/${ADDR}/proofleger3/get-doc`, {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ sender: ADDR, arguments: ["0x0200000020" + HASH] }),
    });
    times.push(Date.now() - start);
    await new Promise(r => setTimeout(r, 100));
  }
  const avg = times.reduce((s,t) => s+t, 0) / times.length;
  const min = Math.min(...times); const max = Math.max(...times);
  console.log(`avg: ${avg.toFixed(0)}ms  min: ${min}ms  max: ${max}ms`);
}
benchmark(10).catch(console.error);