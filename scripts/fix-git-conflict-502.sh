#!/bin/bash

# Git conflict çöz ve script'i çalıştır

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="$HOME/premiumfoto"

echo -e "${BLUE}🔧 Git conflict çözülüyor...${NC}"
echo ""

cd "$APP_DIR"

# 1. Yerel değişiklikleri stash'le
echo -e "${YELLOW}1️⃣ Yerel değişiklikler stash'leniyor...${NC}"
git stash
echo -e "${GREEN}✅ Değişiklikler stash'lendi${NC}"
echo ""

# 2. Git pull yap
echo -e "${YELLOW}2️⃣ Git pull yapılıyor...${NC}"
git pull origin main
echo -e "${GREEN}✅ Git pull tamamlandı${NC}"
echo ""

# 3. Script'i çalıştır
echo -e "${YELLOW}3️⃣ 502 script'i çalıştırılıyor...${NC}"
bash scripts/fix-502-final-complete.sh

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"

