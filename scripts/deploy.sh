#!/bin/bash
# ProofLedger Contract Deployment Script
set -e
NETWORK=${1:-testnet}
DEPLOY_ORDER=("proofleger3" "credentials" "achievements" "endorsements" "profiles" "revocations" "reputation" "collections" "badges" "registry" "governance" "subscriptions" "messaging" "timestamps" "oracle")
RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"; NC="\033[0m"
echo -e "${YELLOW}ProofLedger Deployment — $NETWORK${NC}"
if [ "$NETWORK" = "mainnet" ]; then
  echo -e "${RED}WARNING: Deploying to MAINNET${NC}"
  read -p "Type mainnet to confirm: " c; [ "$c" != "mainnet" ] && exit 1
fi
command -v clarinet &>/dev/null || { echo -e "${RED}clarinet not found${NC}"; exit 1; }
clarinet check && echo -e "${GREEN}Syntax OK${NC}"
clarinet test && echo -e "${GREEN}Tests passed${NC}"
echo -e "${GREEN}Ready to deploy ${#DEPLOY_ORDER[@]} contracts${NC}"
echo "Order: ${DEPLOY_ORDER[*]}"