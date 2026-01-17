#!/bin/bash

# trendyol-manager klasörünü tamamen sil
# Kullanım: bash scripts/remove-trendyol-completely.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="${APP_DIR:-$HOME/premiumfoto}"

echo -e "${YELLOW}🗑️  trendyol-manager klasörü tamamen siliniyor...${NC}"

cd "$APP_DIR"

# 1. trendyol-manager klasörünü sil (eğer varsa)
if [ -d "trendyol-manager" ]; then
    rm -rf trendyol-manager
    echo -e "${GREEN}✅ trendyol-manager klasörü silindi${NC}"
fi

# 2. trendyol-manager.backup klasörünü sil (eğer varsa)
if [ -d "trendyol-manager.backup" ]; then
    rm -rf trendyol-manager.backup
    echo -e "${GREEN}✅ trendyol-manager.backup klasörü silindi${NC}"
fi

# 3. .next cache'i temizle (opsiyonel ama önerilir)
if [ -d ".next" ]; then
    echo -e "${YELLOW}⚠️  .next cache temizleniyor...${NC}"
    rm -rf .next
    echo -e "${GREEN}✅ .next cache temizlendi${NC}"
fi

echo -e "${GREEN}✅ İşlem tamamlandı!${NC}"
echo -e "${YELLOW}💡 Artık build yapabilirsiniz: npm run build${NC}"

