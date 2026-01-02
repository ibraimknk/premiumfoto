#!/bin/bash

# fikirtepetekelpaket.com Nginx config'ini devre dışı bırak

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE="/etc/nginx/sites-available/fikirtepetekelpaket.com"
ENABLED_LINK="/etc/nginx/sites-enabled/fikirtepetekelpaket.com"

echo -e "${YELLOW}🔧 fikirtepetekelpaket.com Nginx config'i devre dışı bırakılıyor...${NC}"

# Config'i devre dışı bırak
if [ -L "$ENABLED_LINK" ]; then
    echo -e "${YELLOW}🗑️  Config devre dışı bırakılıyor...${NC}"
    sudo rm -f "$ENABLED_LINK"
    echo -e "${GREEN}✅ Config devre dışı bırakıldı${NC}"
else
    echo -e "${YELLOW}⚠️  Config zaten devre dışı${NC}"
fi

# Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ fikirtepetekelpaket.com Nginx config'i devre dışı bırakıldı!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol:${NC}"
echo "   ls -la /etc/nginx/sites-enabled/ | grep fikirtepetekelpaket"
echo "   curl -I https://dugunkarem.com.tr"

