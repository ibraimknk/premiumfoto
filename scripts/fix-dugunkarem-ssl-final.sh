#!/bin/bash

# dugunkarem.com SSL yapılandırmasını düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 dugunkarem.com SSL yapılandırması düzeltiliyor...${NC}"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# Mevcut config'i kontrol et
echo -e "${YELLOW}📋 Mevcut SSL yapılandırması:${NC}"
sudo grep -A 5 "listen 443 ssl" "$FOTO_UGUR_CONFIG" | grep -A 5 "dugunkarem"

# dugunkarem.com için SSL server block'unu kontrol et ve düzelt
if ! sudo grep -A 10 "listen 443 ssl" "$FOTO_UGUR_CONFIG" | grep -q "server_name dugunkarem.com dugunkarem.com.tr"; then
    echo -e "${YELLOW}⚠️  dugunkarem.com için SSL yapılandırması bulunamadı veya yanlış${NC}"
    
    # Eski dugunkarem SSL block'unu sil
    sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com SSL yapılandırmasını bul ve sil
# "# dugunkarem.com SSL yapılandırması" ile başlayan ve sonraki server block'u sil
pattern = r'# dugunkarem\.com SSL yapılandırması.*?server \{[^}]*server_name dugunkarem\.com[^}]*\}[^}]*\}'
content = re.sub(pattern, '', content, flags=re.DOTALL)

# dugunkarem.com HTTP redirect block'unu da sil
pattern = r'# dugunkarem\.com HTTP.*?server \{[^}]*server_name dugunkarem\.com[^}]*\}[^}]*\}'
content = re.sub(pattern, '', content, flags=re.DOTALL)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ Eski dugunkarem SSL yapılandırması temizlendi")
PYEOF
    
    # Yeni SSL yapılandırmasını ekle
    echo -e "${YELLOW}📝 Yeni SSL yapılandırması ekleniyor...${NC}"
    
    sudo tee -a "$FOTO_UGUR_CONFIG" > /dev/null << 'EOF'

# dugunkarem.com SSL yapılandırması
server {
    listen 443 ssl http2;
    server_name dugunkarem.com dugunkarem.com.tr;
    
    ssl_certificate /etc/letsencrypt/live/dugunkarem.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dugunkarem.com/privkey.pem;
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
EOF

    echo -e "${GREEN}✅ Yeni SSL yapılandırması eklendi${NC}"
else
    echo -e "${GREEN}✅ dugunkarem.com için SSL yapılandırması mevcut${NC}"
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
echo -e "${GREEN}✅ SSL yapılandırması düzeltildi!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

