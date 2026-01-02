#!/bin/bash

# Nginx config'i temizle ve düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${BLUE}🔧 Nginx config temizleniyor ve düzeltiliyor...${NC}"
echo ""

# 1. Yedek al
echo -e "${YELLOW}1️⃣ Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Yedek alındı${NC}"
echo ""

# 2. Satır 118'i kontrol et
echo -e "${YELLOW}2️⃣ Satır 115-120 kontrol ediliyor...${NC}"
sudo sed -n '115,120p' "$NGINX_CONFIG"
echo ""

# 3. Config dosyasını düzelt
echo -e "${YELLOW}3️⃣ Config dosyası düzeltiliyor...${NC}"
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Boş server block'ları ve hatalı satırları temizle
fixed_lines = []
skip_block = False
brace_count = 0

for i, line in enumerate(lines):
    # Boş server_name satırlarını atla
    if re.match(r'^\s*server_name\s*;\s*$', line):
        continue
    
    # Boş return satırlarını atla
    if re.match(r'^\s*return\s+301\s+https://;\s*$', line):
        continue
    
    # Boş server block başlangıcını tespit et
    if 'server {' in line and not skip_block:
        # Sonraki satırları kontrol et
        if i + 1 < len(lines):
            next_line = lines[i + 1].strip()
            # Eğer sonraki satır boş server_name ise, bu block'u atla
            if re.match(r'^\s*server_name\s*;\s*$', next_line):
                skip_block = True
                brace_count = 1
                continue
    
    if skip_block:
        if '{' in line:
            brace_count += line.count('{')
        if '}' in line:
            brace_count -= line.count('}')
            if brace_count == 0:
                skip_block = False
        continue
    
    # proxy_set_header satırlarını kontrol et ve düzelt
    if 'proxy_set_header' in line:
        # Eğer satırda $ karakteri yoksa veya hatalı formattaysa düzelt
        parts = line.split()
        if len(parts) < 3:
            # Hatalı satır, atla veya düzelt
            continue
        # Eğer $ karakteri eksikse ekle
        if '$' not in line and 'Upgrade' in line:
            line = line.replace('Upgrade', 'Upgrade $http_upgrade')
        elif '$' not in line and 'Connection' in line:
            line = line.replace('Connection "upgrade"', 'Connection "upgrade"')
        elif '$' not in line and 'Host' in line:
            line = line.replace('Host', 'Host $host')
        elif '$' not in line and 'X-Real-IP' in line:
            line = line.replace('X-Real-IP', 'X-Real-IP $remote_addr')
        elif '$' not in line and 'X-Forwarded-For' in line:
            line = line.replace('X-Forwarded-For', 'X-Forwarded-For $proxy_add_x_forwarded_for')
        elif '$' not in line and 'X-Forwarded-Proto' in line:
            line = line.replace('X-Forwarded-Proto', 'X-Forwarded-Proto $scheme')
    
    fixed_lines.append(line)

# Dosyayı yaz
with open(config_file, 'w', encoding='utf-8') as f:
    f.writelines(fixed_lines)

print("Config temizlendi ve düzeltildi")
PYEOF

# 4. dugunkarem.com block'larını ekle (eğer yoksa)
echo -e "${YELLOW}4️⃣ dugunkarem.com block'ları kontrol ediliyor...${NC}"
if ! sudo grep -q "server_name.*dugunkarem.com.*www.dugunkarem.com" "$NGINX_CONFIG"; then
    echo -e "${YELLOW}   dugunkarem.com block'ları ekleniyor...${NC}"
    sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"
target_port = 3040
cert_path = "/etc/letsencrypt/live/fotougur.com.tr"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# dugunkarem.com HTTPS block'u var mı kontrol et
has_dugunkarem_com_https = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*www\.dugunkarem\.com[^}]*listen\s+443',
    content,
    re.DOTALL | re.IGNORECASE
))

if not has_dugunkarem_com_https:
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

# dugunkarem.com SSL yapılandırması (Port 3040)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com www.dugunkarem.com;

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
    }

    location / {
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# dugunkarem.com.tr SSL yapılandırması (Port 3040)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;

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
    }

    location / {
        proxy_pass http://127.0.0.1:3040;
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
    # İlk server block'unu bul ve önüne ekle
    first_server_match = re.search(r'server\s*\{', content)
    if first_server_match:
        insert_pos = first_server_match.start()
        content = content[:insert_pos] + new_blocks + '\n' + content[insert_pos:]
    else:
        content = new_blocks + '\n' + content
    
    with open(config_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("dugunkarem.com block'ları eklendi")
else:
    print("dugunkarem.com block'ları zaten mevcut")
PYEOF
fi

# 5. Nginx test
echo ""
echo -e "${YELLOW}5️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx restart ediliyor...${NC}"
    sudo systemctl restart nginx
    sleep 3
    echo -e "${GREEN}✅ Nginx restart edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}📋 Hata detayları:${NC}"
    sudo nginx -t 2>&1 | head -10
    echo ""
    echo -e "${YELLOW}💡 Satır 115-120:${NC}"
    sudo sed -n '115,120p' "$NGINX_CONFIG"
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
