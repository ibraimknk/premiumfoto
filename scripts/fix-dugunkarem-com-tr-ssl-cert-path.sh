#!/bin/bash

# dugunkarem.com.tr için SSL sertifika path'ini düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="dugunkarem.com.tr"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"

echo -e "${YELLOW}🔧 ${DOMAIN} için SSL sertifika path'i düzeltiliyor...${NC}"

# 1. dugunkarem.com.tr için SSL server block'unu bul
echo -e "${YELLOW}🔍 SSL server block aranıyor...${NC}"

# Python ile config'i düzelt
sudo python3 << PYEOF
import re

config_file = "${FOTO_UGUR_CONFIG}"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com.tr içeren SSL server block'unu bul
# listen 443 ile başlayan ve dugunkarem.com.tr içeren server block
pattern = r'(server\s*\{[^}]*listen\s+443[^}]*server_name[^}]*dugunkarem\.com\.tr[^}]*)(.*?)(\})'

def fix_ssl_cert_path(match):
    block_start = match.group(1)
    block_content = match.group(2)
    block_end = match.group(3)
    
    cert_path = "${CERT_PATH}"
    
    # Mevcut ssl_certificate satırlarını değiştir veya ekle
    if 'ssl_certificate' in block_start or 'ssl_certificate' in block_content:
        # Mevcut sertifika path'lerini değiştir
        block_start = re.sub(r'ssl_certificate\s+[^;]+;', f'ssl_certificate {cert_path}/fullchain.pem;', block_start)
        block_start = re.sub(r'ssl_certificate_key\s+[^;]+;', f'ssl_certificate_key {cert_path}/privkey.pem;', block_start)
        block_content = re.sub(r'ssl_certificate\s+[^;]+;', f'ssl_certificate {cert_path}/fullchain.pem;', block_content)
        block_content = re.sub(r'ssl_certificate_key\s+[^;]+;', f'ssl_certificate_key {cert_path}/privkey.pem;', block_content)
    else:
        # SSL sertifika satırlarını ekle
        ssl_config = f'''
    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
'''
        block_start = block_start.rstrip() + ssl_config
    
    # return 404 satırlarını kaldır
    block_content = re.sub(r'\s*return\s+404[^;]*;', '', block_content)
    block_content = re.sub(r'\s*#\s*managed by Certbot', '', block_content)
    
    # proxy_pass var mı kontrol et
    if 'proxy_pass' not in block_content:
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

content = re.sub(pattern, fix_ssl_cert_path, content, flags=re.DOTALL)

# Çoklu boş satırları temizle
content = re.sub(r'\n\n\n+', '\n\n', content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ Config düzeltildi")
PYEOF

# 2. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ SSL sertifika path'i düzeltildi!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://${DOMAIN}"
echo "   openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} < /dev/null 2>/dev/null | openssl x509 -noout -subject"

