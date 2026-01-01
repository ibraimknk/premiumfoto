#!/bin/bash

# dugunkarem config dosyasını devre dışı bırak ve temizle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DUGUNKAREM_CONFIG="/etc/nginx/sites-available/dugunkarem"
DUGUNKAREM_ENABLED="/etc/nginx/sites-enabled/dugunkarem"

echo -e "${YELLOW}🗑️  dugunkarem config dosyası devre dışı bırakılıyor...${NC}"

# sites-enabled'dan kaldır
if [ -L "$DUGUNKAREM_ENABLED" ] || [ -f "$DUGUNKAREM_ENABLED" ]; then
    sudo rm -f "$DUGUNKAREM_ENABLED"
    echo -e "${GREEN}✅ dugunkarem config sites-enabled'dan kaldırıldı${NC}"
else
    echo -e "${YELLOW}⚠️  dugunkarem config zaten devre dışı${NC}"
fi

# Config dosyasını yedekle ve temizle
if [ -f "$DUGUNKAREM_CONFIG" ]; then
    sudo cp "$DUGUNKAREM_CONFIG" "${DUGUNKAREM_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✅ Config yedeklendi${NC}"
    
    # Config dosyasını boşalt veya sil (opsiyonel)
    echo -e "${YELLOW}⚠️  dugunkarem config dosyası mevcut: $DUGUNKAREM_CONFIG${NC}"
    echo -e "${YELLOW}💡 İsterseniz dosyayı silebilirsiniz: sudo rm $DUGUNKAREM_CONFIG${NC}"
fi

# Nginx test
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ dugunkarem config devre dışı bırakıldı!${NC}"
echo -e "${YELLOW}📋 Artık dugunkarem.com sadece foto-ugur config'inde yönlenecek${NC}"

