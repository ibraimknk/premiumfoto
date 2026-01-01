#!/bin/bash

# dugunkarem.com SSL yapılandırmasını doğrula

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔍 dugunkarem.com SSL yapılandırması doğrulanıyor...${NC}"

# 1. Sertifika dosyalarını kontrol et
echo ""
echo -e "${YELLOW}1️⃣ Sertifika dosyaları:${NC}"
if [ -f "$CERT_PATH/fullchain.pem" ]; then
    echo -e "${GREEN}✅ fullchain.pem bulundu${NC}"
    sudo openssl x509 -in "$CERT_PATH/fullchain.pem" -noout -subject -dates 2>/dev/null | head -2
else
    echo -e "${RED}❌ fullchain.pem bulunamadı: $CERT_PATH/fullchain.pem${NC}"
fi

if [ -f "$CERT_PATH/privkey.pem" ]; then
    echo -e "${GREEN}✅ privkey.pem bulundu${NC}"
else
    echo -e "${RED}❌ privkey.pem bulunamadı: $CERT_PATH/privkey.pem${NC}"
fi

# 2. Sertifika içindeki domain'leri kontrol et
echo ""
echo -e "${YELLOW}2️⃣ Sertifika içindeki domain'ler:${NC}"
if [ -f "$CERT_PATH/fullchain.pem" ]; then
    sudo openssl x509 -in "$CERT_PATH/fullchain.pem" -noout -text 2>/dev/null | grep -A 2 "Subject Alternative Name" || sudo openssl x509 -in "$CERT_PATH/fullchain.pem" -noout -text 2>/dev/null | grep "DNS:"
fi

# 3. Nginx config'inde dugunkarem.com server block'unu kontrol et
echo ""
echo -e "${YELLOW}3️⃣ Nginx config'inde dugunkarem.com server block:${NC}"
sudo grep -B 2 -A 20 "server_name dugunkarem.com dugunkarem.com.tr" "$FOTO_UGUR_CONFIG" | head -25

# 4. Tüm 443 portu server block'larını listele
echo ""
echo -e "${YELLOW}4️⃣ Tüm 443 portu server block'ları:${NC}"
sudo grep -B 5 -A 5 "listen 443" "$FOTO_UGUR_CONFIG" | grep -E "server_name|ssl_certificate|listen 443"

# 5. Nginx test
echo ""
echo -e "${YELLOW}5️⃣ Nginx config test:${NC}"
if sudo nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    sudo nginx -t
fi

# 6. Test önerisi
echo ""
echo -e "${YELLOW}6️⃣ Test:${NC}"
echo "   curl -vI https://dugunkarem.com 2>&1 | grep -E 'subject|CN|DNS'"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -A 2 'Subject Alternative Name'"

