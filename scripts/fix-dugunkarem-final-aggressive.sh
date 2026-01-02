#!/bin/bash

# dugunkarem.com için agresif düzeltme - fikirtepetekelpaket.com'u devre dışı bırak

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
FIKIRTEPE_CONFIG="/etc/nginx/sites-available/fikirtepetekelpaket"
FIKIRTEPE_ENABLED="/etc/nginx/sites-enabled/fikirtepetekelpaket.com"
TARGET_PORT=3040

echo -e "${BLUE}🔧 dugunkarem.com agresif düzeltme...${NC}"
echo ""

# 1. fikirtepetekelpaket.com config'ini devre dışı bırak
echo -e "${YELLOW}1️⃣ fikirtepetekelpaket.com config'i devre dışı bırakılıyor...${NC}"
if [ -L "$FIKIRTEPE_ENABLED" ]; then
    sudo rm "$FIKIRTEPE_ENABLED"
    echo -e "${GREEN}✅ fikirtepetekelpaket.com config devre dışı bırakıldı${NC}"
else
    echo -e "${YELLOW}⚠️  fikirtepetekelpaket.com config zaten devre dışı${NC}"
fi

# Config dosyasından dugunkarem domain'lerini kaldır
if [ -f "$FIKIRTEPE_CONFIG" ]; then
    sudo python3 << PYEOF
import re

config_file = "$FIKIRTEPE_CONFIG"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# dugunkarem.com ve dugunkarem.com.tr'yi server_name'lerden kaldır
content = re.sub(
    r'\bdugunkarem\.com\b',
    '',
    content
)
content = re.sub(
    r'\bdugunkarem\.com\.tr\b',
    '',
    content
)

# Boş server_name satırlarını temizle
content = re.sub(r'server_name\s+;', 'server_name fikirtepetekelpaket.com;', content)
content = re.sub(r'server_name\s+\s+', 'server_name fikirtepetekelpaket.com;', content)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF
    echo -e "${GREEN}✅ fikirtepetekelpaket.com config'inden dugunkarem domain'leri kaldırıldı${NC}"
fi
echo ""

# 2. foto-ugur config'ini temizle ve dugunkarem.com block'larını en başa ekle
echo -e "${YELLOW}2️⃣ foto-ugur config'i düzeltiliyor...${NC}"
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT
cert_path = "/etc/letsencrypt/live/fotougur.com.tr"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Tüm dugunkarem.com server block'larını kaldır (yeniden oluşturacağız)
# HTTP redirect block'ları
content = re.sub(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+80[^}]*\}',
    '',
    content,
    flags=re.DOTALL | re.IGNORECASE
)

# HTTPS block'ları
content = re.sub(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+443[^}]*\}',
    '',
    content,
    flags=re.DOTALL | re.IGNORECASE
)

# dugunkarem.com.tr block'ları
content = re.sub(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\.tr\b[^}]*\}',
    '',
    content,
    flags=re.DOTALL | re.IGNORECASE
)

# www.www. gibi tekrarları temizle
content = re.sub(r'www\.www\.', 'www.', content)

# Yeni block'ları oluştur (en başa eklenecek)
# $ karakterlerini escape etmek için $$ kullan
new_blocks = f'''
# dugunkarem.com HTTP -> HTTPS redirect
server {{
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com www.dugunkarem.com;
    return 301 https://dugunkarem.com$$request_uri;
}}

# dugunkarem.com.tr HTTP -> HTTPS redirect
server {{
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;
    return 301 https://dugunkarem.com.tr$$request_uri;
}}

# dugunkarem.com SSL yapılandırması (Port {target_port})
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com www.dugunkarem.com;

    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    location /uploads {{
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }}

    location / {{
        proxy_pass http://127.0.0.1:{target_port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $$host;
        proxy_set_header X-Real-IP $$remote_addr;
        proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $$scheme;
    }}
}}

# dugunkarem.com.tr SSL yapılandırması (Port {target_port})
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;

    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    location /uploads {{
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }}

    location / {{
        proxy_pass http://127.0.0.1:{target_port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $$host;
        proxy_set_header X-Real-IP $$remote_addr;
        proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $$scheme;
    }}
}}
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

# 3. sites-enabled/foto-ugur kontrolü (symlink mi dosya mı?)
echo -e "${YELLOW}3️⃣ sites-enabled/foto-ugur kontrol ediliyor...${NC}"
FOTO_UGUR_ENABLED="/etc/nginx/sites-enabled/foto-ugur"
if [ -f "$FOTO_UGUR_ENABLED" ] && [ ! -L "$FOTO_UGUR_ENABLED" ]; then
    echo -e "${YELLOW}   sites-enabled/foto-ugur bir dosya, symlink'e çevriliyor...${NC}"
    sudo mv "$FOTO_UGUR_ENABLED" "${FOTO_UGUR_ENABLED}.backup.$(date +%Y%m%d_%H%M%S)"
    sudo ln -s "$NGINX_CONFIG" "$FOTO_UGUR_ENABLED"
    echo -e "${GREEN}✅ Symlink oluşturuldu${NC}"
elif [ ! -L "$FOTO_UGUR_ENABLED" ]; then
    echo -e "${YELLOW}   Symlink oluşturuluyor...${NC}"
    sudo ln -s "$NGINX_CONFIG" "$FOTO_UGUR_ENABLED"
    echo -e "${GREEN}✅ Symlink oluşturuldu${NC}"
else
    echo -e "${GREEN}✅ Symlink zaten mevcut${NC}"
fi
echo ""

# 4. Nginx test ve restart
echo -e "${YELLOW}4️⃣ Nginx test ediliyor...${NC}"
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

# 5. Test
echo ""
echo -e "${YELLOW}5️⃣ Domain testleri:${NC}"
sleep 2
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

# 6. Nginx error log kontrolü
echo ""
echo -e "${YELLOW}6️⃣ Nginx error log (son 5 satır - dugunkarem):${NC}"
sudo tail -5 /var/log/nginx/error.log | grep -i "dugunkarem" || echo "   dugunkarem ile ilgili hata yok"

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"

