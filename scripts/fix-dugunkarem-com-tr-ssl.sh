#!/bin/bash

# dugunkarem.com.tr SSL sertifikası sorununu çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="dugunkarem.com.tr"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
CERT_PATH="/etc/letsencrypt/live/fotougur.com.tr"

echo -e "${YELLOW}🔧 ${DOMAIN} SSL sertifikası sorunu çözülüyor...${NC}"

# 1. fotougur.com.tr sertifikasının dugunkarem.com.tr'yi kapsadığını kontrol et
echo -e "${YELLOW}🔍 Sertifika kontrol ediliyor...${NC}"

if [ -f "${CERT_PATH}/fullchain.pem" ]; then
    echo -e "${GREEN}✅ fotougur.com.tr sertifikası mevcut${NC}"
    
    # Sertifikada hangi domainler var?
    CERT_DOMAINS=$(sudo openssl x509 -in "${CERT_PATH}/fullchain.pem" -noout -text | grep -A1 "Subject Alternative Name" | grep "DNS:" | sed 's/DNS://g' | tr ',' '\n' | xargs)
    echo -e "${YELLOW}📋 Sertifikadaki domainler: ${CERT_DOMAINS}${NC}"
    
    if echo "$CERT_DOMAINS" | grep -q "dugunkarem.com.tr"; then
        echo -e "${GREEN}✅ Sertifika ${DOMAIN}'i kapsıyor${NC}"
    else
        echo -e "${YELLOW}⚠️  Sertifika ${DOMAIN}'i kapsamıyor, genişletiliyor...${NC}"
        sudo certbot --nginx -d fotougur.com.tr -d www.fotougur.com.tr -d dugunkarem.com -d www.dugunkarem.com -d ${DOMAIN} -d www.${DOMAIN} --expand --non-interactive --agree-tos --email ibrahim@example.com 2>&1 || {
            echo -e "${YELLOW}⚠️  Certbot başarısız, manuel kurulum gerekebilir${NC}"
        }
    fi
else
    echo -e "${RED}❌ fotougur.com.tr sertifikası bulunamadı!${NC}"
    exit 1
fi

# 2. Config'teki return 404 satırlarını kaldır ve doğru yapılandırmayı sağla
echo -e "${YELLOW}📝 Config düzeltiliyor...${NC}"

sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com.tr için SSL server block'unda return 404'leri kaldır
# ve proxy_pass ekle (yoksa)

# Önce dugunkarem.com.tr içeren SSL server block'unu bul
pattern = r'(server\s*\{[^}]*listen\s+443[^}]*server_name[^}]*dugunkarem\.com\.tr[^}]*)(.*?)(\})'

def fix_ssl_block(match):
    block_start = match.group(1)
    block_content = match.group(2)
    block_end = match.group(3)
    
    # return 404 satırlarını kaldır
    block_content = re.sub(r'\s*return\s+404[^;]*;', '', block_content)
    block_content = re.sub(r'\s*#\s*managed by Certbot', '', block_content)
    
    # SSL sertifika path'lerini kontrol et ve düzelt
    if 'ssl_certificate' not in block_start:
        # SSL sertifika satırlarını ekle
        ssl_config = '''
    ssl_certificate /etc/letsencrypt/live/fotougur.com.tr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/fotougur.com.tr/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
'''
        block_start = block_start.rstrip() + ssl_config
    
    # proxy_pass var mı kontrol et
    if 'proxy_pass' not in block_content:
        # location / block'u ekle
        location_block = '''
    location / {
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
'''
        block_content = location_block + block_content
    
    return block_start + block_content + block_end

content = re.sub(pattern, fix_ssl_block, content, flags=re.DOTALL)

# Çoklu boş satırları temizle
content = re.sub(r'\n\n\n+', '\n\n', content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ Config düzeltildi")
PYEOF

# 3. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}💡 Config dosyasını kontrol edin:${NC}"
    echo "   sudo nano $FOTO_UGUR_CONFIG"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ ${DOMAIN} SSL sertifikası sorunu çözüldü!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://${DOMAIN}"
echo "   openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} < /dev/null 2>/dev/null | openssl x509 -noout -subject"

