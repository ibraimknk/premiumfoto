#!/bin/bash

# fikirtepetekelpaket.com SSL sertifikası sorununu çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="fikirtepetekelpaket.com"
CONFIG_FILE="/etc/nginx/sites-available/fikirtepetekelpaket.com"

echo -e "${YELLOW}🔧 ${DOMAIN} SSL sertifikası sorunu çözülüyor...${NC}"

# 1. Mevcut sertifika kontrolü
echo -e "${YELLOW}🔍 Mevcut sertifikalar kontrol ediliyor...${NC}"

# Tüm sertifika dizinlerini listele
CERT_DIRS=$(sudo ls -d /etc/letsencrypt/live/*/ 2>/dev/null | xargs -n1 basename)

echo -e "${YELLOW}📋 Mevcut sertifikalar:${NC}"
for cert_dir in $CERT_DIRS; do
    echo "   - $cert_dir"
done

# 2. fikirtepetekelpaket.com için sertifika var mı?
if [ -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo -e "${GREEN}✅ ${DOMAIN} sertifikası mevcut${NC}"
    CERT_PATH="/etc/letsencrypt/live/${DOMAIN}"
else
    echo -e "${YELLOW}⚠️  ${DOMAIN} sertifikası bulunamadı, oluşturuluyor...${NC}"
    
    # Önce HTTP config'i ile test et
    sudo nginx -t && sudo systemctl reload nginx || {
        echo -e "${RED}❌ Nginx config hatası!${NC}"
        exit 1
    }
    
    # Certbot ile SSL kur
    echo -e "${YELLOW}📝 Certbot ile SSL sertifikası kuruluyor...${NC}"
    sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email ibrahim@example.com --expand 2>&1 || {
        echo -e "${YELLOW}⚠️  Certbot başarısız, manuel kurulum gerekebilir${NC}"
        echo -e "${YELLOW}💡 Manuel kurulum:${NC}"
        echo "   sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --expand"
    }
    
    CERT_PATH="/etc/letsencrypt/live/${DOMAIN}"
fi

# 3. Config dosyasını güncelle
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}📝 Config dosyası güncelleniyor...${NC}"
    
    # SSL sertifika path'lerini güncelle
    sudo sed -i "s|ssl_certificate.*fikirtepetekelpaket\.com.*|ssl_certificate ${CERT_PATH}/fullchain.pem;|g" "$CONFIG_FILE"
    sudo sed -i "s|ssl_certificate_key.*fikirtepetekelpaket\.com.*|ssl_certificate_key ${CERT_PATH}/privkey.pem;|g" "$CONFIG_FILE"
    
    echo -e "${GREEN}✅ Config dosyası güncellendi${NC}"
else
    echo -e "${RED}❌ Config dosyası bulunamadı: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}💡 Önce setup-fikirtepetekelpaket-3000.sh script'ini çalıştırın${NC}"
    exit 1
fi

# 4. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}💡 Config dosyasını kontrol edin:${NC}"
    echo "   sudo nano $CONFIG_FILE"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ SSL sertifikası sorunu çözüldü!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://${DOMAIN}"
echo "   openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} < /dev/null 2>/dev/null | openssl x509 -noout -subject"

