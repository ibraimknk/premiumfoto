#!/bin/bash

# Git conflict'i çöz ve Nginx config'i düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Git conflict çözülüyor ve Nginx düzeltiliyor...${NC}"
echo ""

# Git conflict çöz
echo -e "${YELLOW}1️⃣ Git conflict çözülüyor...${NC}"
cd ~/premiumfoto
git stash
git pull origin main
echo -e "${GREEN}✅ Git güncellendi${NC}"
echo ""

# Script'i çalıştır
echo -e "${YELLOW}2️⃣ Nginx config düzeltiliyor...${NC}"
chmod +x scripts/fix-nginx-all-errors-complete.sh
sudo bash scripts/fix-nginx-all-errors-complete.sh

