#!/bin/bash

# foto-ugur config'indeki www.www.dugunkarem.com.tr gibi kalıntıları temizle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🧹 www.www.dugunkarem.com.tr gibi kalıntılar temizleniyor...${NC}"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# www.www. gibi kalıntıları temizle
sudo sed -i 's/www\.www\.dugunkarem\.com\.tr//g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/www\.www\.//g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/www\.www\.fotougur\.com\.tr/www.fotougur.com.tr/g' "$FOTO_UGUR_CONFIG"

# Çoklu boşlukları temizle
sudo sed -i 's/server_name  */server_name /g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/ ;/;/g' "$FOTO_UGUR_CONFIG"

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
echo -e "${GREEN}✅ Kalıntılar temizlendi!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -subject"

