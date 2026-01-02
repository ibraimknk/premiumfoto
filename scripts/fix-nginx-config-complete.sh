#!/bin/bash

# Nginx config'i tamamen düzelt (dugunkarem.com için)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${BLUE}🔧 Nginx config tamamen düzeltiliyor...${NC}"
echo ""

# 1. Yedek al
echo -e "${YELLOW}1️⃣ Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Yedek alındı${NC}"
echo ""

# 2. Config dosyasının ilk 20 satırını göster
echo -e "${YELLOW}2️⃣ Config dosyasının ilk 20 satırı:${NC}"
sudo head -20 "$NGINX_CONFIG"
echo ""

# 3. Config dosyasını Python ile düzelt
echo -e "${YELLOW}3️⃣ Config dosyası düzeltiliyor...${NC}"
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Tüm satırları işle
fixed_lines = []
i = 0
skip_until_brace_close = False
brace_count = 0

while i < len(lines):
    line = lines[i]
    original_line = line
    
    # Boş satırları atla (çok fazla boş satır varsa)
    if line.strip() == '' and len(fixed_lines) > 0 and fixed_lines[-1].strip() == '':
        i += 1
        continue
    
    # Eğer bir server block düzgün kapanmamışsa, kapat
    if skip_until_brace_close:
        if '{' in line:
            brace_count += line.count('{')
        if '}' in line:
            brace_count -= line.count('}')
            if brace_count == 0:
                skip_until_brace_close = False
                fixed_lines.append(line)
        i += 1
        continue
    
    # Boş server block'ları atla
    if 'server {' in line:
        # Sonraki birkaç satırı kontrol et
        next_lines = ''.join(lines[i:i+5])
        if re.search(r'server\s*\{\s*server_name\s*;\s*\}', next_lines, re.DOTALL):
            # Boş server block, atla
            brace_count = 1
            j = i + 1
            while j < len(lines) and brace_count > 0:
                if '{' in lines[j]:
                    brace_count += lines[j].count('{')
                if '}' in lines[j]:
                    brace_count -= lines[j].count('}')
                j += 1
            i = j
            continue
    
    # Hatalı server_name satırlarını atla
    if re.match(r'^\s*server_name\s*;\s*$', line):
        i += 1
        continue
    
    # Hatalı return satırlarını atla
    if re.match(r'^\s*return\s+301\s+https://;\s*$', line):
        i += 1
        continue
    
    # Location block'u server block'unun dışındaysa, önceki server block'u kapat
    if 'location /' in line and not skip_until_brace_close:
        # Önceki satırları kontrol et
        if len(fixed_lines) > 0:
            # Son birkaç satırı kontrol et
            last_lines = ''.join(fixed_lines[-10:])
            if not re.search(r'server\s*\{[^}]*$', last_lines, re.DOTALL):
                # Server block yok, ekle
                fixed_lines.append('server {\n')
                fixed_lines.append('    listen 443 ssl http2;\n')
                fixed_lines.append('    listen [::]:443 ssl http2;\n')
                fixed_lines.append('    server_name _;\n')
                fixed_lines.append('\n')
    
    # proxy_set_header satırlarını düzelt
    if 'proxy_set_header' in line:
        # Eksik değerleri ekle
        if 'Upgrade' in line and '$http_upgrade' not in line:
            line = '        proxy_set_header Upgrade $http_upgrade;\n'
        elif 'Connection' in line and 'upgrade' not in line and '"upgrade"' not in line:
            line = '        proxy_set_header Connection "upgrade";\n'
        elif 'Host' in line and '$host' not in line:
            line = '        proxy_set_header Host $host;\n'
        elif 'X-Real-IP' in line and '$remote_addr' not in line:
            line = '        proxy_set_header X-Real-IP $remote_addr;\n'
        elif 'X-Forwarded-For' in line and '$proxy_add_x_forwarded_for' not in line:
            line = '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n'
        elif 'X-Forwarded-Proto' in line and '$scheme' not in line:
            line = '        proxy_set_header X-Forwarded-Proto $scheme;\n'
        # Eğer sadece "proxy_set_header" varsa, atla
        elif re.match(r'^\s*proxy_set_header\s*;\s*$', line):
            i += 1
            continue
    
    fixed_lines.append(line)
    i += 1

# Config'i birleştir
content = ''.join(fixed_lines)

# Tüm dugunkarem.com block'larını kaldır
content = re.sub(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*?\}[^}]*?\}',
    '',
    content,
    flags=re.DOTALL | re.IGNORECASE
)

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

# Tüm proxy_pass'leri port 3040'a çevir (dugunkarem için)
content = re.sub(
    r'(server_name[^}]*\bdugunkarem\.com[^}]*?proxy_pass\s+http://127\.0\.0\.1:)\d+',
    r'\g<1>3040',
    content,
    flags=re.DOTALL | re.IGNORECASE
)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config düzeltildi")
PYEOF

# 4. Nginx test
echo ""
echo -e "${YELLOW}4️⃣ Nginx test ediliyor...${NC}"
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
    echo -e "${YELLOW}💡 Satır 1-20:${NC}"
    sudo head -20 "$NGINX_CONFIG"
    echo ""
    echo -e "${YELLOW}💡 Satır 10-15:${NC}"
    sudo sed -n '10,15p' "$NGINX_CONFIG"
    exit 1
fi

# 5. Test
echo ""
echo -e "${YELLOW}5️⃣ Domain testleri:${NC}"
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

