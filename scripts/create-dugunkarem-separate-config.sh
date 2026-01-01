#!/bin/bash

# dugunkarem.com için ayrı bir Nginx config dosyası oluştur

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DUGUNKAREM_CONFIG="/etc/nginx/sites-available/dugunkarem-3040"
DUGUNKAREM_ENABLED="/etc/nginx/sites-enabled/dugunkarem-3040"

echo -e "${YELLOW}🔧 dugunkarem.com için ayrı config dosyası oluşturuluyor...${NC}"

# foto-ugur config'inden dugunkarem.com server block'unu al
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

# dugunkarem.com için server block'u kontrol et
if sudo grep -q "dugunkarem.com" "$FOTO_UGUR_CONFIG"; then
    echo -e "${YELLOW}⚠️  foto-ugur config'inde dugunkarem.com block'u bulundu, kaldırılacak...${NC}"
    REMOVE_FROM_FOTO_UGUR=true
else
    echo -e "${GREEN}✅ foto-ugur config'inde dugunkarem.com block'u yok${NC}"
    REMOVE_FROM_FOTO_UGUR=false
fi

# Yeni config dosyası oluştur
echo -e "${YELLOW}📝 Yeni config dosyası oluşturuluyor...${NC}"

sudo tee "$DUGUNKAREM_CONFIG" > /dev/null << 'EOF'
# dugunkarem.com SSL yapılandırması (Port 3040 - premiumfoto)
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
EOF

echo -e "${GREEN}✅ Config dosyası oluşturuldu${NC}"

# foto-ugur config'inden dugunkarem.com block'larını kaldır
if [ "$REMOVE_FROM_FOTO_UGUR" = true ]; then
    echo -e "${YELLOW}📝 foto-ugur config'inden dugunkarem.com block'ları kaldırılıyor...${NC}"
    
    # Geçici dosya oluştur
    TEMP_FILE=$(mktemp)
    
    # dugunkarem.com içeren satırları ve sonraki server block'larını kaldır
    sudo awk '
    /dugunkarem\.com/ {
        in_block = 1
        skip = 1
    }
    skip && /^[[:space:]]*server[[:space:]]*\{/ {
        brace_count = 1
        skip = 1
    }
    skip && /\{/ {
        brace_count++
    }
    skip && /\}/ {
        brace_count--
        if (brace_count == 0) {
            skip = 0
            next
        }
    }
    !skip {
        print
    }
    ' "$FOTO_UGUR_CONFIG" > "$TEMP_FILE"
    
    # Çoklu boş satırları temizle
    sudo sed -i '/^$/N;/^\n$/d' "$TEMP_FILE"
    
    # Dosyayı değiştir
    sudo mv "$TEMP_FILE" "$FOTO_UGUR_CONFIG"
    sudo chmod 644 "$FOTO_UGUR_CONFIG"
    
    echo -e "${GREEN}✅ foto-ugur config'inden dugunkarem.com block'ları kaldırıldı${NC}"
fi

# Yeni config'i aktif et
echo -e "${YELLOW}📝 Yeni config aktif ediliyor...${NC}"
sudo ln -sf "$DUGUNKAREM_CONFIG" "$DUGUNKAREM_ENABLED"
echo -e "${GREEN}✅ Config aktif edildi${NC}"

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
echo -e "${GREEN}✅ dugunkarem.com için ayrı config dosyası oluşturuldu!${NC}"
echo -e "${YELLOW}📋 Config dosyası: $DUGUNKAREM_CONFIG${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -subject"

