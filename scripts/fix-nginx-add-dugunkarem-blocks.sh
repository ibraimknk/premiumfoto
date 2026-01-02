#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr için server block'ları ekle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${YELLOW}🔧 dugunkarem.com ve dugunkarem.com.tr için server block'ları ekleniyor...${NC}"

if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
    exit 1
fi

# Yedek al
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# SSL sertifika yolu
CERT_PATH="/etc/letsencrypt/live/fotougur.com.tr"

# Python ile server block'ları ekle
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT
cert_path = "$CERT_PATH"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# dugunkarem.com ve dugunkarem.com.tr için server block'ları var mı kontrol et
has_dugunkarem_http = False
has_dugunkarem_https = False
has_dugunkarem_tr_http = False
has_dugunkarem_tr_https = False

# HTTP (port 80) server block'ları
if re.search(r'server\s*\{[^}]*server_name[^}]*dugunkarem\.com[^}]*listen\s+80', content, re.DOTALL):
    has_dugunkarem_http = True

# HTTPS (port 443) server block'ları
if re.search(r'server\s*\{[^}]*server_name[^}]*dugunkarem\.com[^}]*listen\s+443', content, re.DOTALL):
    has_dugunkarem_https = True

if re.search(r'server\s*\{[^}]*server_name[^}]*dugunkarem\.com\.tr[^}]*listen\s+80', content, re.DOTALL):
    has_dugunkarem_tr_http = True

if re.search(r'server\s*\{[^}]*server_name[^}]*dugunkarem\.com\.tr[^}]*listen\s+443', content, re.DOTALL):
    has_dugunkarem_tr_https = True

# Server block'ları ekle
new_blocks = []

# dugunkarem.com HTTP -> HTTPS redirect
if not has_dugunkarem_http:
    new_blocks.append('''
# dugunkarem.com HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com www.dugunkarem.com;
    
    location / {
        return 301 https://dugunkarem.com$request_uri;
    }
}
''')

# dugunkarem.com.tr HTTP -> HTTPS redirect
if not has_dugunkarem_tr_http:
    new_blocks.append('''
# dugunkarem.com.tr HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;
    
    location / {
        return 301 https://dugunkarem.com.tr$request_uri;
    }
}
''')

# dugunkarem.com HTTPS
if not has_dugunkarem_https:
    new_blocks.append(f'''
# dugunkarem.com SSL yapılandırması (Port {target_port} - premiumfoto)
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com www.dugunkarem.com;

    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    # Uploads için statik dosya servisi
    location /uploads {{
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }}

    location / {{
        proxy_pass http://127.0.0.1:{target_port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
''')

# dugunkarem.com.tr HTTPS
if not has_dugunkarem_tr_https:
    new_blocks.append(f'''
# dugunkarem.com.tr SSL yapılandırması (Port {target_port} - premiumfoto)
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;

    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    # Uploads için statik dosya servisi
    location /uploads {{
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }}

    location / {{
        proxy_pass http://127.0.0.1:{target_port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
''')

# Yeni block'ları dosyanın başına ekle (ilk server block'undan önce)
if new_blocks:
    # İlk server block'unu bul
    first_server_match = re.search(r'server\s*\{', content)
    if first_server_match:
        insert_pos = first_server_match.start()
        content = content[:insert_pos] + '\n'.join(new_blocks) + '\n' + content[insert_pos:]
    else:
        # Server block yoksa, dosyanın sonuna ekle
        content = content + '\n'.join(new_blocks)
    
    print(f"{len(new_blocks)} server block eklendi")
else:
    print("Tüm server block'lar zaten mevcut")

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    sudo nginx -t
    exit 1
fi

# Kontrol
echo ""
echo -e "${YELLOW}🔍 dugunkarem.com server block'ları kontrol ediliyor...${NC}"
if sudo grep -q "server_name.*dugunkarem.com" "$NGINX_CONFIG"; then
    echo -e "${GREEN}✅ dugunkarem.com server block'ları mevcut${NC}"
    sudo grep -A 2 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | head -10
else
    echo -e "${RED}❌ dugunkarem.com server block'ları bulunamadı!${NC}"
fi

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"

