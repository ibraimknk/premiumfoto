#!/bin/bash

# dugunkarem.com SSL yapılandırmasını Nginx'e basit şekilde ekle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"

echo -e "${YELLOW}🔒 dugunkarem.com SSL yapılandırması ekleniyor...${NC}"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# www. www. tekrarlarını temizle
echo -e "${YELLOW}🧹 Config temizleniyor...${NC}"
sudo sed -i 's/www\. www\./www.fotougur.com.tr/g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/server_name  */server_name /g' "$FOTO_UGUR_CONFIG"

# 443 portu için SSL server block ekle
echo -e "${YELLOW}📝 SSL yapılandırması ekleniyor...${NC}"

sudo tee -a "$FOTO_UGUR_CONFIG" > /dev/null << 'EOF'

# dugunkarem.com SSL yapılandırması
server {
    listen 443 ssl;
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
    if ($host = dugunkarem.com) {
        return 301 https://$host$request_uri;
    }
    if ($host = dugunkarem.com.tr) {
        return 301 https://$host$request_uri;
    }
    listen 80;
    server_name dugunkarem.com dugunkarem.com.tr;
    return 404;
}
EOF

echo -e "${GREEN}✅ SSL yapılandırması eklendi${NC}"

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
echo -e "${GREEN}✅ SSL kurulumu tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

