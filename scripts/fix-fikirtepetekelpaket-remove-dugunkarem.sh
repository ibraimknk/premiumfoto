#!/bin/bash

# fikirtepetekelpaket.com config'inden dugunkarem.com'u tamamen kaldır

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FIKIRTEPETE_CONFIG="/etc/nginx/sites-available/fikirtepetekelpaket.com"

echo -e "${YELLOW}🔧 fikirtepetekelpaket.com config'inden dugunkarem.com kaldırılıyor...${NC}"

if [ ! -f "$FIKIRTEPETE_CONFIG" ]; then
    echo -e "${RED}❌ Config bulunamadı: $FIKIRTEPETE_CONFIG${NC}"
    exit 1
fi

# Config yedekle
sudo cp "$FIKIRTEPETE_CONFIG" "${FIKIRTEPETE_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# dugunkarem.com içeriyor mu kontrol et
if sudo grep -q "dugunkarem\.com" "$FIKIRTEPETE_CONFIG"; then
    echo -e "${YELLOW}⚠️  dugunkarem.com bulundu, temizleniyor...${NC}"
    
    # Tüm dugunkarem referanslarını kaldır
    sudo sed -i 's/dugunkarem\.com\.tr//g' "$FIKIRTEPETE_CONFIG"
    sudo sed -i 's/www\.dugunkarem\.com\.tr//g' "$FIKIRTEPETE_CONFIG"
    sudo sed -i 's/dugunkarem\.com//g' "$FIKIRTEPETE_CONFIG"
    sudo sed -i 's/www\.dugunkarem\.com//g' "$FIKIRTEPETE_CONFIG"
    
    # Çoklu boşlukları temizle
    sudo sed -i 's/server_name  */server_name /g' "$FIKIRTEPETE_CONFIG"
    sudo sed -i 's/ ;/;/g' "$FIKIRTEPETE_CONFIG"
    
    echo -e "${GREEN}✅ dugunkarem.com kaldırıldı${NC}"
else
    echo -e "${GREEN}✅ dugunkarem.com zaten yok${NC}"
fi

# Config'i göster
echo ""
echo -e "${YELLOW}📋 Güncel config:${NC}"
sudo grep -B 3 -A 10 "server_name\|listen.*443" "$FIKIRTEPETE_CONFIG" | head -20

# Nginx test
echo ""
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
echo -e "${GREEN}✅ fikirtepetekelpaket.com config'i temizlendi!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -subject"

