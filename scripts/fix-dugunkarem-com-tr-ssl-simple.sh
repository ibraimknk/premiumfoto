#!/bin/bash

# dugunkarem.com.tr SSL sertifikası sorununu çöz (www olmadan)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="dugunkarem.com.tr"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 ${DOMAIN} SSL sertifikası sorunu çözülüyor...${NC}"

# 1. Mevcut sertifikaları kontrol et
echo -e "${YELLOW}🔍 Mevcut sertifikalar kontrol ediliyor...${NC}"

# dugunkarem.com sertifikası var mı?
if [ -f "/etc/letsencrypt/live/dugunkarem.com/fullchain.pem" ]; then
    CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"
    echo -e "${GREEN}✅ dugunkarem.com sertifikası mevcut${NC}"
    
    # Sertifikada dugunkarem.com.tr var mı?
    CERT_DOMAINS=$(sudo openssl x509 -in "${CERT_PATH}/fullchain.pem" -noout -text 2>/dev/null | grep -A1 "Subject Alternative Name" | grep "DNS:" | sed 's/DNS://g' | tr ',' '\n' | xargs || echo "")
    
    if echo "$CERT_DOMAINS" | grep -q "dugunkarem.com.tr"; then
        echo -e "${GREEN}✅ Sertifika ${DOMAIN}'i kapsıyor${NC}"
    else
        echo -e "${YELLOW}📝 Sertifika genişletiliyor (www olmadan)...${NC}"
        sudo certbot --nginx -d dugunkarem.com -d ${DOMAIN} --expand --non-interactive --agree-tos --email ibrahim@example.com 2>&1 || {
            echo -e "${YELLOW}⚠️  Certbot başarısız, manuel kurulum gerekebilir${NC}"
        }
    fi
else
    # Yeni sertifika oluştur (www olmadan)
    echo -e "${YELLOW}📝 Yeni sertifika oluşturuluyor (www olmadan)...${NC}"
    sudo certbot --nginx -d dugunkarem.com -d ${DOMAIN} --non-interactive --agree-tos --email ibrahim@example.com 2>&1 || {
        echo -e "${RED}❌ Sertifika oluşturulamadı!${NC}"
        exit 1
    }
    CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"
fi

# 2. Config'teki SSL sertifika path'lerini düzelt
echo -e "${YELLOW}📝 Config düzeltiliyor...${NC}"

# dugunkarem.com.tr için SSL server block'unda sertifika path'ini düzelt
sudo sed -i "s|ssl_certificate.*dugunkarem\.com[^;]*;|ssl_certificate ${CERT_PATH}/fullchain.pem;|g" "$FOTO_UGUR_CONFIG" 2>/dev/null || true
sudo sed -i "s|ssl_certificate_key.*dugunkarem\.com[^;]*;|ssl_certificate_key ${CERT_PATH}/privkey.pem;|g" "$FOTO_UGUR_CONFIG" 2>/dev/null || true

# Eğer dugunkarem.com.tr için SSL block'unda sertifika yoksa ekle
if ! sudo grep -A 10 "server_name.*dugunkarem.com.tr" "$FOTO_UGUR_CONFIG" | grep -q "ssl_certificate"; then
    echo -e "${YELLOW}📝 SSL sertifika satırları ekleniyor...${NC}"
    
    sudo python3 << PYEOF
import re

config_file = "${FOTO_UGUR_CONFIG}"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com.tr için SSL server block'unu bul ve sertifika ekle
pattern = r'(server\s*\{[^}]*listen\s+443[^}]*server_name[^}]*dugunkarem\.com\.tr[^}]*)(\n)'

def add_ssl_cert(match):
    block_start = match.group(1)
    newline = match.group(2)
    
    if 'ssl_certificate' not in block_start:
        ssl_config = f'''{newline}    ssl_certificate {CERT_PATH}/fullchain.pem;
    ssl_certificate_key {CERT_PATH}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
'''
        return block_start + ssl_config
    return match.group(0)

content = re.sub(pattern, add_ssl_cert, content, flags=re.DOTALL)

# return 404 satırlarını kaldır
content = re.sub(r'\s*return\s+404[^;]*;', '', content)
content = re.sub(r'\s*#\s*managed by Certbot', '', content)

# Çoklu boş satırları temizle
content = re.sub(r'\n\n\n+', '\n\n', content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ Config düzeltildi")
PYEOF
fi

# 3. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ ${DOMAIN} SSL sertifikası sorunu çözüldü!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://${DOMAIN}"

