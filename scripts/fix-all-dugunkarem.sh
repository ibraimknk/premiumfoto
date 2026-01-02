#!/bin/bash

# dugunkarem.com için tüm sorunları çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${BLUE}🔧 dugunkarem.com için tüm sorunlar çözülüyor...${NC}"
echo ""

cd ~/premiumfoto

# 1. Git conflict çöz
echo -e "${YELLOW}1️⃣ Git conflict çözülüyor...${NC}"
git stash
git pull origin main
echo -e "${GREEN}✅ Git conflict çözüldü${NC}"
echo ""

# 2. fikirtepetekelpaket.com'u devre dışı bırak
echo -e "${YELLOW}2️⃣ fikirtepetekelpaket.com devre dışı bırakılıyor...${NC}"
sudo rm -f /etc/nginx/sites-enabled/fikirtepetekelpaket.com
echo -e "${GREEN}✅ fikirtepetekelpaket.com devre dışı${NC}"
echo ""

# 3. Nginx config'i düzelt - dugunkarem.com block'larını en başa ekle
echo -e "${YELLOW}3️⃣ Nginx config düzeltiliyor...${NC}"
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT
cert_path = "/etc/letsencrypt/live/fotougur.com.tr"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Tüm dugunkarem.com server block'larını kaldır
content = re.sub(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*\}',
    '',
    content,
    flags=re.DOTALL | re.IGNORECASE
)

# Yeni block'ları oluştur (düzgün format ile)
new_blocks = '''# dugunkarem.com HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com www.dugunkarem.com;
    return 301 https://dugunkarem.com$request_uri;
}

# dugunkarem.com.tr HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;
    return 301 https://dugunkarem.com.tr$request_uri;
}

# dugunkarem.com SSL yapılandırması (Port ''' + str(target_port) + ''')
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com www.dugunkarem.com;

    ssl_certificate ''' + cert_path + '''/fullchain.pem;
    ssl_certificate_key ''' + cert_path + '''/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    location /uploads {
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location / {
        proxy_pass http://127.0.0.1:''' + str(target_port) + ''';
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# dugunkarem.com.tr SSL yapılandırması (Port ''' + str(target_port) + ''')
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;

    ssl_certificate ''' + cert_path + '''/fullchain.pem;
    ssl_certificate_key ''' + cert_path + '''/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    location /uploads {
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location / {
        proxy_pass http://127.0.0.1:''' + str(target_port) + ''';
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
'''

# Block'ları dosyanın en başına ekle
content = new_blocks + '\n' + content

# Tüm proxy_pass'leri port 3040'a çevir
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:3001',
    f'proxy_pass http://127.0.0.1:{target_port}',
    content
)
content = re.sub(
    r'proxy_pass\s+http://localhost:3001',
    f'proxy_pass http://127.0.0.1:{target_port}',
    content
)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi - dugunkarem.com block'ları en başa eklendi")
PYEOF

# 4. sites-enabled/foto-ugur symlink kontrolü
echo -e "${YELLOW}4️⃣ sites-enabled/foto-ugur kontrol ediliyor...${NC}"
FOTO_UGUR_ENABLED="/etc/nginx/sites-enabled/foto-ugur"
if [ -f "$FOTO_UGUR_ENABLED" ] && [ ! -L "$FOTO_UGUR_ENABLED" ]; then
    sudo mv "$FOTO_UGUR_ENABLED" "${FOTO_UGUR_ENABLED}.backup.$(date +%Y%m%d_%H%M%S)"
    sudo ln -s "$NGINX_CONFIG" "$FOTO_UGUR_ENABLED"
    echo -e "${GREEN}✅ Symlink oluşturuldu${NC}"
elif [ ! -L "$FOTO_UGUR_ENABLED" ]; then
    sudo ln -s "$NGINX_CONFIG" "$FOTO_UGUR_ENABLED"
    echo -e "${GREEN}✅ Symlink oluşturuldu${NC}"
fi
echo ""

# 5. Nginx test
echo -e "${YELLOW}5️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx restart ediliyor...${NC}"
    sudo systemctl restart nginx
    sleep 3
    echo -e "${GREEN}✅ Nginx restart edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    sudo nginx -t
    exit 1
fi

# 6. Test
echo ""
echo -e "${YELLOW}6️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr")
for domain in "${DOMAINS[@]}"; do
    echo -e "${YELLOW}   Test ediliyor: https://${domain}${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 -k https://${domain} 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}   ✅ ${domain}: HTTPS ${HTTP_CODE}${NC}"
    else
        echo -e "${RED}   ❌ ${domain}: HTTPS ${HTTP_CODE}${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"

