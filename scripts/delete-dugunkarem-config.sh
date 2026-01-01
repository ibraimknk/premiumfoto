#!/bin/bash

# dugunkarem config dosyasını tamamen sil

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DUGUNKAREM_CONFIG="/etc/nginx/sites-available/dugunkarem"
DUGUNKAREM_ENABLED="/etc/nginx/sites-enabled/dugunkarem"

echo -e "${YELLOW}🗑️  dugunkarem config dosyası siliniyor...${NC}"

# sites-enabled'dan kaldır
if [ -L "$DUGUNKAREM_ENABLED" ] || [ -f "$DUGUNKAREM_ENABLED" ]; then
    sudo rm -f "$DUGUNKAREM_ENABLED"
    echo -e "${GREEN}✅ dugunkarem config sites-enabled'dan kaldırıldı${NC}"
fi

# Config dosyasını yedekle ve sil
if [ -f "$DUGUNKAREM_CONFIG" ]; then
    sudo cp "$DUGUNKAREM_CONFIG" "${DUGUNKAREM_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✅ Config yedeklendi${NC}"
    
    sudo rm "$DUGUNKAREM_CONFIG"
    echo -e "${GREEN}✅ dugunkarem config dosyası silindi${NC}"
else
    echo -e "${YELLOW}⚠️  dugunkarem config dosyası zaten yok${NC}"
fi

# Nginx test
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
    sudo systemctl daemon-reload
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ dugunkarem config dosyası silindi!${NC}"
echo -e "${YELLOW}📋 Artık dugunkarem.com sadece foto-ugur config'inde yönlenecek (port 3040)${NC}"

