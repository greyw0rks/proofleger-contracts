// Usage: AGENT_MNEMONIC="..." node scripts/fund-wallet.js SP_ADDRESS AMOUNT_STX
import walletPkg from "@stacks/wallet-sdk/dist/index.js";
const { generateWallet, getStxAddress } = walletPkg;
import txPkg from "@stacks/transactions";
const { makeSTXTokenTransfer, broadcastTransaction, AnchorMode } = txPkg;
import netPkg from "@stacks/network";
const { STACKS_MAINNET } = netPkg;

const [,, recipient, amountStx] = process.argv;
if (!recipient || !amountStx) { console.error("Usage: node fund-wallet.js SP_ADDRESS AMOUNT_STX"); process.exit(1); }

async function fund() {
  const mnemonic = process.env.AGENT_MNEMONIC;
  if (!mnemonic) { console.error("Set AGENT_MNEMONIC"); process.exit(1); }
  const wallet = await generateWallet({ secretKey: mnemonic, password: "" });
  const account = wallet.accounts[0];
  const senderKey = account.stxPrivateKey;
  const amount = BigInt(Math.floor(parseFloat(amountStx) * 1_000_000));
  const tx = await makeSTXTokenTransfer({ recipient, amount, senderKey, network: STACKS_MAINNET, anchorMode: AnchorMode.Any, fee: 1000n });
  const result = await broadcastTransaction({ transaction: tx, network: STACKS_MAINNET });
  console.log(result.error ? `Error: ${result.error}` : `Funded! TX: ${result.txid}`);
}

fund().catch(console.error);