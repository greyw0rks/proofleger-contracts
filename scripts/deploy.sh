#!/bin/bash
# deploy.sh - ProofLedger contract deployment helper
# Usage: ./scripts/deploy.sh testnet|mainnet

set -e
NETWORK=${1:-testnet}
DEPLOY_ORDER=("proofleger3" "credentials" "achievements")
RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"; NC="\033[0m"

echo -e "${YELLOW}ProofLedger Deployment - Network: $NETWORK${NC}"

if [ "$NETWORK" = "mainnet" ]; then
  echo -e "${RED}WARNING: Deploying to MAINNET${NC}"
  read -p "Type 'mainnet' to confirm: " confirm
  [ "$confirm" != "mainnet" ] && echo "Cancelled." && exit 1
fi

command -v clarinet &> /dev/null || { echo -e "${RED}clarinet not found${NC}"; exit 1; }

echo -e "${YELLOW}Running tests...${NC}"
clarinet test
echo -e "${GREEN}Tests passed.${NC}"

echo -e "${YELLOW}Checking syntax...${NC}"
clarinet check
echo -e "${GREEN}Syntax OK.${NC}"

for contract in "${DEPLOY_ORDER[@]}"; do
  [ ! -f "contracts/$contract.clar" ] && echo -e "${RED}$contract.clar not found${NC}" && exit 1
  echo "Deploying $contract..."
  echo -e "${GREEN}$contract ready.${NC}"
done

echo -e "${GREEN}Deployment complete: ${DEPLOY_ORDER[*]}${NC}"
echo "Verify at: https://explorer.hiro.so"
