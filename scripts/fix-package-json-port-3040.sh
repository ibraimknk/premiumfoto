#!/bin/bash

# package.json'daki start script'ini port 3040'a geri döndür

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="/home/ibrahim/premiumfoto"
PACKAGE_JSON="${APP_DIR}/package.json"

echo -e "${YELLOW}🔧 package.json start script'i port 3040'a düzeltiliyor...${NC}"

# package.json'ı kontrol et
if [ ! -f "$PACKAGE_JSON" ]; then
    echo -e "${RED}❌ package.json bulunamadı: $PACKAGE_JSON${NC}"
    exit 1
fi

# Start script'ini 3040'a düzelt
sed -i 's/"start": "next start -p [0-9]*/"start": "next start -p 3040/' "$PACKAGE_JSON"

echo -e "${GREEN}✅ package.json güncellendi${NC}"
echo -e "${YELLOW}📋 Kontrol:${NC}"
grep '"start"' "$PACKAGE_JSON"

