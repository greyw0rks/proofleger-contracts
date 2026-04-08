import { createHash } from "crypto";
const TEST_DOCS = [
  "Bachelor of Science - Computer Science - MIT 2024",
  "Certificate of Completion - Advanced Solidity - Consensys Academy",
  "Research Paper: Zero-Knowledge Proofs in Identity Systems",
  "NFT Artwork: Genesis Collection #001",
  "Open Source Contribution: Stacks Core v2.5",
  "Hackathon Winner: ETHGlobal London 2024",
  "Professional Certificate: AWS Solutions Architect",
];
console.log("Test document hashes:\n");
TEST_DOCS.forEach((doc, i) => {
  const hash = createHash("sha256").update(doc).digest("hex");
  console.log(`${i+1}. ${doc}`);
  console.log(`   Hash: ${hash}`);
  console.log(`   Verify: https://proofleger.vercel.app/verify?hash=${hash}\n`);
});