#!/bin/bash

# dugunkarem.com için çalışan çözüm

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${BLUE}🔧 dugunkarem.com çözüm...${NC}"
echo ""

# Home dizinini bul
if [ "$EUID" -eq 0 ]; then
    # Root ise, ibrahim kullanıcısının home dizinini kullan
    HOME_DIR="/home/ibrahim"
else
    HOME_DIR="$HOME"
fi

cd "$HOME_DIR/premiumfoto"

# 1. Git conflict çöz (agresif)
echo -e "${YELLOW}1️⃣ Git conflict çözülüyor...${NC}"
git stash || true
git fetch origin main
git reset --hard origin/main
echo -e "${GREEN}✅ Git conflict çözüldü${NC}"
echo ""

# 2. fikirtepetekelpaket.com'u devre dışı bırak
echo -e "${YELLOW}2️⃣ fikirtepetekelpaket.com devre dışı bırakılıyor...${NC}"
sudo rm -f /etc/nginx/sites-enabled/fikirtepetekelpaket.com
sudo rm -f /etc/nginx/sites-enabled/fikirtepetekelpake.com
echo -e "${GREEN}✅ fikirtepetekelpaket.com devre dışı${NC}"
echo ""

# 3. Config dosyasının ilk 10 satırını kontrol et
echo -e "${YELLOW}3️⃣ Config dosyasının ilk 10 satırı kontrol ediliyor...${NC}"
sudo head -10 "$NGINX_CONFIG"
echo ""

# 4. Nginx config'i düzelt - sed ile
echo -e "${YELLOW}4️⃣ Nginx config düzeltiliyor (sed ile)...${NC}"

# Yedek al
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# Boş server_name satırlarını temizle
sudo sed -i '/^[[:space:]]*server_name[[:space:]]*;$/d' "$NGINX_CONFIG"
sudo sed -i 's/server_name[[:space:]]*;[[:space:]]*$/server_name fotougur.com.tr;/' "$NGINX_CONFIG"

# dugunkarem.com block'larını en başa ekle (heredoc ile)
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# İlk satırları kontrol et - eğer boş server_name varsa düzelt
lines = content.split('\n')
fixed_lines = []

for i, line in enumerate(lines):
    # Boş server_name satırlarını atla
    if re.match(r'^\s*server_name\s*;\s*$', line):
        continue
    # server_name ile başlayan ama sadece ; olan satırları düzelt
    if re.match(r'^\s*server_name\s+;\s*$', line):
        continue
    fixed_lines.append(line)

content = '\n'.join(fixed_lines)

# dugunkarem.com block'larını kontrol et
has_dugunkarem_com_https = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+443',
    content,
    re.DOTALL | re.IGNORECASE
))

if not has_dugunkarem_com_https:
    # Yeni block'ları ekle
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
content = re.sub(
    r'proxy_pass\s+http://localhost:3001',
    'proxy_pass http://127.0.0.1:3040',
    content
)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# 5. Config dosyasının ilk 10 satırını tekrar kontrol et
echo ""
echo -e "${YELLOW}5️⃣ Config dosyasının ilk 10 satırı (güncellenmiş):${NC}"
sudo head -10 "$NGINX_CONFIG"
echo ""

# 6. Nginx test
echo -e "${YELLOW}6️⃣ Nginx test ediliyor...${NC}"
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
    echo -e "${YELLOW}💡 Config dosyasının ilk 20 satırı:${NC}"
    sudo head -20 "$NGINX_CONFIG"
    exit 1
fi

# 7. Test
echo ""
echo -e "${YELLOW}7️⃣ Domain testleri:${NC}"
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

