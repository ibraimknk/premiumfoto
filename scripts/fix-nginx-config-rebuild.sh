#!/bin/bash

# Nginx config'i yeniden oluştur (dugunkarem.com için)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${BLUE}🔧 Nginx config yeniden oluşturuluyor...${NC}"
echo ""

# 1. Yedek al
echo -e "${YELLOW}1️⃣ Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Yedek alındı${NC}"
echo ""

# 2. Mevcut config'den sadece fotougur.com.tr block'larını al
echo -e "${YELLOW}2️⃣ Mevcut config'den fotougur.com.tr block'ları alınıyor...${NC}"
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Tüm dugunkarem.com block'larını kaldır
content = re.sub(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*\}',
    '',
    content,
    flags=re.DOTALL | re.IGNORECASE
)

# Boş server block'ları kaldır
content = re.sub(r'server\s*\{\s*\}', '', content, flags=re.DOTALL)
content = re.sub(r'server\s*\{\s*server_name\s*;\s*\}', '', content, flags=re.DOTALL)

# Hatalı proxy_set_header satırlarını düzelt
lines = content.split('\n')
fixed_lines = []
in_location = False
location_brace_count = 0

for i, line in enumerate(lines):
    # Location block başlangıcı
    if 'location /' in line and '{' in line:
        in_location = True
        location_brace_count = 1
        fixed_lines.append(line)
        continue
    
    if in_location:
        if '{' in line:
            location_brace_count += line.count('{')
        if '}' in line:
            location_brace_count -= line.count('}')
        
        # proxy_set_header satırlarını düzelt
        if 'proxy_set_header' in line:
            # Eksik değerleri ekle
            if 'Upgrade' in line and '$http_upgrade' not in line:
                line = '        proxy_set_header Upgrade $http_upgrade;'
            elif 'Connection' in line and 'upgrade' not in line:
                line = '        proxy_set_header Connection "upgrade";'
            elif 'Host' in line and '$host' not in line:
                line = '        proxy_set_header Host $host;'
            elif 'X-Real-IP' in line and '$remote_addr' not in line:
                line = '        proxy_set_header X-Real-IP $remote_addr;'
            elif 'X-Forwarded-For' in line and '$proxy_add_x_forwarded_for' not in line:
                line = '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;'
            elif 'X-Forwarded-Proto' in line and '$scheme' not in line:
                line = '        proxy_set_header X-Forwarded-Proto $scheme;'
        
        fixed_lines.append(line)
        
        if location_brace_count == 0:
            in_location = False
    else:
        fixed_lines.append(line)

content = '\n'.join(fixed_lines)

# dugunkarem.com block'larını ekle (en başa)
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

# Tüm proxy_pass'leri port 3040'a çevir
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:3001',
    'proxy_pass http://127.0.0.1:3040',
    content
)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config yeniden oluşturuldu")
PYEOF

# 3. Nginx test
echo ""
echo -e "${YELLOW}3️⃣ Nginx test ediliyor...${NC}"
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
    echo -e "${YELLOW}💡 Satır 180-190:${NC}"
    sudo sed -n '180,190p' "$NGINX_CONFIG"
    exit 1
fi

# 4. Test
echo ""
echo -e "${YELLOW}4️⃣ Domain testleri:${NC}"
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

