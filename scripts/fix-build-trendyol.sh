#!/bin/bash

# trendyol-manager klasörünü build'den hariç tutmak için script
# Kullanım: bash scripts/fix-build-trendyol.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="${APP_DIR:-$HOME/premiumfoto}"

echo -e "${YELLOW}🔧 trendyol-manager klasörü build'den hariç tutuluyor...${NC}"

cd "$APP_DIR"

# 1. trendyol-manager klasörünü taşı (eğer varsa)
if [ -d "trendyol-manager" ]; then
    echo -e "${YELLOW}⚠️  trendyol-manager klasörü bulundu${NC}"
    
    # Klasörü geçici olarak taşı
    if [ ! -d "trendyol-manager.backup" ]; then
        mv trendyol-manager trendyol-manager.backup
        echo -e "${GREEN}✅ trendyol-manager klasörü geçici olarak taşındı${NC}"
    else
        echo -e "${YELLOW}⚠️  trendyol-manager.backup zaten var, siliniyor...${NC}"
        rm -rf trendyol-manager
    fi
else
    echo -e "${GREEN}✅ trendyol-manager klasörü zaten yok${NC}"
fi

# 2. .gitignore'ı kontrol et
if ! grep -q "trendyol-manager" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# trendyol-manager (build'den hariç tutulacak)" >> .gitignore
    echo "/trendyol-manager" >> .gitignore
    echo -e "${GREEN}✅ .gitignore güncellendi${NC}"
fi

echo -e "${GREEN}✅ İşlem tamamlandı!${NC}"
echo -e "${YELLOW}💡 Artık build yapabilirsiniz: npm run build${NC}"

