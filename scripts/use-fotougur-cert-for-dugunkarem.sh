#!/bin/bash

# dugunkarem.com için fotougur.com.tr sertifikasını kullan (çünkü o da dugunkarem.com'u içeriyor)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
FOTOUGUR_CERT="/etc/letsencrypt/live/fotougur.com.tr/fullchain.pem"
FOTOUGUR_KEY="/etc/letsencrypt/live/fotougur.com.tr/privkey.pem"

echo -e "${YELLOW}🔧 dugunkarem.com için fotougur.com.tr sertifikası kullanılıyor...${NC}"

# Sertifika dosyalarını kontrol et
if [ ! -f "$FOTOUGUR_CERT" ] || [ ! -f "$FOTOUGUR_KEY" ]; then
    echo -e "${YELLOW}⚠️  fotougur.com.tr sertifikası bulunamadı, aranıyor...${NC}"
    
    # Sertifika dosyalarını ara
    FOTOUGUR_CERT_FOUND=$(sudo find /etc/letsencrypt -name "*fotougur*" -name "fullchain.pem" 2>/dev/null | head -1)
    FOTOUGUR_KEY_FOUND=$(sudo find /etc/letsencrypt -name "*fotougur*" -name "privkey.pem" 2>/dev/null | head -1)
    
    if [ -n "$FOTOUGUR_CERT_FOUND" ] && [ -n "$FOTOUGUR_KEY_FOUND" ]; then
        FOTOUGUR_CERT="$FOTOUGUR_CERT_FOUND"
        FOTOUGUR_KEY="$FOTOUGUR_KEY_FOUND"
        echo -e "${GREEN}✅ Sertifika bulundu: $FOTOUGUR_CERT${NC}"
    else
        echo -e "${RED}❌ fotougur.com.tr sertifikası bulunamadı!${NC}"
        echo -e "${YELLOW}💡 Mevcut sertifikalar:${NC}"
        sudo certbot certificates 2>/dev/null | grep -E "Certificate Name|Domains" | head -10
        exit 1
    fi
fi

echo -e "${GREEN}✅ fotougur.com.tr sertifikası bulundu${NC}"

# Sertifika içindeki domain'leri kontrol et
echo -e "${YELLOW}📋 Sertifika içindeki domain'ler:${NC}"
sudo openssl x509 -in "$FOTOUGUR_CERT" -noout -text 2>/dev/null | grep -A 2 "Subject Alternative Name" || sudo openssl x509 -in "$FOTOUGUR_CERT" -noout -text 2>/dev/null | grep "DNS:"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# dugunkarem.com SSL yapılandırmasını güncelle
echo -e "${YELLOW}📝 Nginx config güncelleniyor...${NC}"

sudo sed -i "s|ssl_certificate /etc/letsencrypt/live/dugunkarem.com/fullchain.pem|ssl_certificate $FOTOUGUR_CERT|g" "$FOTO_UGUR_CONFIG"
sudo sed -i "s|ssl_certificate_key /etc/letsencrypt/live/dugunkarem.com/privkey.pem|ssl_certificate_key $FOTOUGUR_KEY|g" "$FOTO_UGUR_CONFIG"

echo -e "${GREEN}✅ Config güncellendi${NC}"

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
echo -e "${GREEN}✅ dugunkarem.com artık fotougur.com.tr sertifikasını kullanıyor!${NC}"
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

