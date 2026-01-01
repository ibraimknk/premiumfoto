#!/bin/bash

# dugunkarem.com için server block önceliğini düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 dugunkarem.com için server block önceliği düzeltiliyor...${NC}"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# dugunkarem.com için server block'unu config'in en başına taşı
echo -e "${YELLOW}📝 dugunkarem.com server block'u en başa taşınıyor...${NC}"

sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com için server block'u bul
dugunkarem_block = None
dugunkarem_redirect_block = None

# 443 portu için dugunkarem.com server block'u
pattern_443 = r'(# dugunkarem\.com SSL yapılandırması\s*server\s*\{[^}]*server_name\s+dugunkarem\.com\s+dugunkarem\.com\.tr[^}]*listen\s+443[^}]*\})'
match_443 = re.search(pattern_443, content, re.DOTALL)
if match_443:
    dugunkarem_block = match_443.group(0)
    # Block'u içerikten kaldır
    content = content.replace(dugunkarem_block, "")

# 80 portu için dugunkarem.com redirect block'u
pattern_80 = r'(# dugunkarem\.com HTTP[^}]*server\s*\{[^}]*server_name\s+dugunkarem\.com\s+dugunkarem\.com\.tr[^}]*listen\s+80[^}]*\})'
match_80 = re.search(pattern_80, content, re.DOTALL)
if match_80:
    dugunkarem_redirect_block = match_80.group(0)
    # Block'u içerikten kaldır
    content = content.replace(dugunkarem_redirect_block, "")

# Eğer block'lar bulunduysa, en başa ekle
if dugunkarem_block or dugunkarem_redirect_block:
    new_blocks = ""
    if dugunkarem_block:
        new_blocks += dugunkarem_block + "\n\n"
    if dugunkarem_redirect_block:
        new_blocks += dugunkarem_redirect_block + "\n\n"
    
    # Config'in en başına ekle
    content = new_blocks + content
    print("✅ dugunkarem.com server block'u en başa taşındı")
else:
    print("⚠️  dugunkarem.com server block'u bulunamadı, yeni oluşturuluyor...")
    
    # Yeni block oluştur
    new_block = '''# dugunkarem.com SSL yapılandırması
server {
    listen 443 ssl http2;
    server_name dugunkarem.com dugunkarem.com.tr;
    
    ssl_certificate /etc/letsencrypt/live/fotougur.com.tr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/fotougur.com.tr/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    client_max_body_size 50M;
    
    location /uploads {
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
        try_files $uri =404;
    }
    
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
}

# dugunkarem.com HTTP'den HTTPS'e yönlendirme
server {
    listen 80;
    server_name dugunkarem.com dugunkarem.com.tr;
    
    if ($host = dugunkarem.com) {
        return 301 https://$host$request_uri;
    }
    if ($host = dugunkarem.com.tr) {
        return 301 https://$host$request_uri;
    }
    
    return 404;
}

'''
    content = new_block + content
    print("✅ dugunkarem.com server block'u oluşturuldu ve en başa eklendi")

with open(config_file, 'w') as f:
    f.write(content)
PYEOF

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
echo -e "${GREEN}✅ dugunkarem.com server block'u en başa taşındı!${NC}"
echo -e "${YELLOW}📋 Artık dugunkarem.com için öncelikli server block kullanılacak${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -subject"

