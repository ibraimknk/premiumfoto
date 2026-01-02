#!/bin/bash

# fikirtepetekelpaket.com'u port 3001'e yönlendir

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="fikirtepetekelpaket.com"
APP_PORT=3001
CONFIG_FILE="/etc/nginx/sites-available/fikirtepetekelpaket.com"
ENABLED_LINK="/etc/nginx/sites-enabled/fikirtepetekelpaket.com"

echo -e "${YELLOW}🔧 ${DOMAIN} port ${APP_PORT}'e yönlendiriliyor...${NC}"

# Nginx config oluştur
echo -e "${YELLOW}📝 Nginx config oluşturuluyor...${NC}"

sudo tee "$CONFIG_FILE" > /dev/null << EOF
# HTTP - HTTPS'e yönlendirme
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    
    # HTTPS'e yönlendir
    return 301 https://\$host\$request_uri;
}

# HTTPS - Port 3001'e proxy
server {
    listen 443 ssl http2;
    server_name ${DOMAIN} www.${DOMAIN};
    
    # SSL sertifikası
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    client_max_body_size 50M;
    
    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeout ayarları
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

echo -e "${GREEN}✅ Nginx config oluşturuldu${NC}"

# Config'i aktif et
echo -e "${YELLOW}📝 Config aktif ediliyor...${NC}"
sudo ln -sf "$CONFIG_FILE" "$ENABLED_LINK"
echo -e "${GREEN}✅ Config aktif edildi${NC}"

# SSL sertifikası kontrolü
echo -e "${YELLOW}🔒 SSL sertifikası kontrol ediliyor...${NC}"
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo -e "${YELLOW}⚠️  SSL sertifikası bulunamadı, kuruluyor...${NC}"
    
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
else
    echo -e "${GREEN}✅ SSL sertifikası mevcut${NC}"
fi

# Nginx test ve reload
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
echo -e "${GREEN}✅ ${DOMAIN} başarıyla port ${APP_PORT}'e yönlendirildi!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol:${NC}"
echo "   curl -I https://${DOMAIN}"
echo "   sudo nginx -t"
echo ""
echo -e "${YELLOW}💡 Port ${APP_PORT}'de uygulama çalıştığından emin olun!${NC}"

