#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr 502 hatasını kesin çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${YELLOW}🔧 dugunkarem.com ve dugunkarem.com.tr 502 hatası kesin çözülüyor...${NC}"

# 1. Port 3040 kontrolü (curl ile)
echo -e "${YELLOW}🔍 Port ${TARGET_PORT} kontrol ediliyor...${NC}"
if ! curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:${TARGET_PORT} | grep -q "200\|301\|302"; then
    echo -e "${RED}❌ Port ${TARGET_PORT} çalışmıyor!${NC}"
    echo -e "${YELLOW}💡 foto-ugur-app'i başlatın:${NC}"
    echo "   cd ~/premiumfoto && pm2 restart foto-ugur-app"
    exit 1
fi
echo -e "${GREEN}✅ Port ${TARGET_PORT} çalışıyor${NC}"

# 2. Nginx config'i kontrol et ve düzelt
if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
    exit 1
fi

# Yedek al
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# 3. Tüm config dosyalarında dugunkarem.com'u bul
echo -e "${YELLOW}📝 Tüm Nginx config dosyaları kontrol ediliyor...${NC}"

# fikirtepetekelpaket.com config'ini tamamen devre dışı bırak
if [ -f "/etc/nginx/sites-available/fikirtepetekelpaket" ]; then
    if [ -L "/etc/nginx/sites-enabled/fikirtepetekelpaket" ]; then
        sudo rm /etc/nginx/sites-enabled/fikirtepetekelpaket
        echo -e "${GREEN}✅ fikirtepetekelpaket.com config devre dışı bırakıldı${NC}"
    fi
fi

# 4. foto-ugur config'ini düzelt
echo -e "${YELLOW}📝 foto-ugur config düzeltiliyor...${NC}"

sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT
cert_path = "/etc/letsencrypt/live/fotougur.com.tr"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Tüm dugunkarem.com için proxy_pass'leri port 3040'a çevir
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:3001',
    f'proxy_pass http://127.0.0.1:{target_port}',
    content
)

# 2. dugunkarem.com ve dugunkarem.com.tr için server block'ları var mı kontrol et
has_dugunkarem_com_https = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+443',
    content,
    re.DOTALL | re.IGNORECASE
))

has_dugunkarem_com_tr_https = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\.tr\b[^}]*listen\s+443',
    content,
    re.DOTALL | re.IGNORECASE
))

# 3. Eğer yoksa, ekle
new_blocks = []

if not has_dugunkarem_com_https:
    new_blocks.append(f'''
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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
''')

if not has_dugunkarem_com_tr_https:
    new_blocks.append(f'''
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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
''')

# 4. HTTP -> HTTPS redirect block'ları ekle
has_dugunkarem_com_http = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+80',
    content,
    re.DOTALL | re.IGNORECASE
))

has_dugunkarem_com_tr_http = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\.tr\b[^}]*listen\s+80',
    content,
    re.DOTALL | re.IGNORECASE
))

if not has_dugunkarem_com_http:
    new_blocks.insert(0, '''
# dugunkarem.com HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com www.dugunkarem.com;
    return 301 https://dugunkarem.com$request_uri;
}
''')

if not has_dugunkarem_com_tr_http:
    new_blocks.insert(1, '''
# dugunkarem.com.tr HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;
    return 301 https://dugunkarem.com.tr$request_uri;
}
''')

# 5. Yeni block'ları dosyanın başına ekle
if new_blocks:
    # İlk server block'unu bul
    first_server_match = re.search(r'server\s*\{', content)
    if first_server_match:
        insert_pos = first_server_match.start()
        content = content[:insert_pos] + '\n'.join(new_blocks) + '\n' + content[insert_pos:]
        print(f"{len(new_blocks)} server block eklendi")
    else:
        # Server block yoksa, dosyanın sonuna ekle
        content = content + '\n'.join(new_blocks)
        print(f"{len(new_blocks)} server block eklendi")
else:
    print("Tüm server block'lar zaten mevcut")

# 6. Mevcut dugunkarem.com block'larındaki proxy_pass'leri düzelt
lines = content.split('\n')
result_lines = []
i = 0
in_dugunkarem_block = False
in_server_block = False

while i < len(lines):
    line = lines[i]
    
    # Server block başlangıcı
    if 'server {' in line or 'server{' in line:
        in_server_block = True
        in_dugunkarem_block = False
    
    # Server name kontrolü
    if in_server_block and 'server_name' in line:
        if 'dugunkarem.com' in line:
            in_dugunkarem_block = True
    
    # Location / bloğu
    if in_dugunkarem_block and 'location /' in line and '{' in line:
        # Location bloğunu kontrol et ve düzelt
        location_start = i
        location_end = i
        brace_count = 0
        
        for j in range(i, len(lines)):
            if '{' in lines[j]:
                brace_count += lines[j].count('{')
            if '}' in lines[j]:
                brace_count -= lines[j].count('}')
            if brace_count == 0 and '}' in lines[j]:
                location_end = j
                break
        
        location_block = '\n'.join(lines[location_start:location_end+1])
        
        if f'proxy_pass http://127.0.0.1:{target_port}' not in location_block:
            result_lines.append(lines[location_start])
            
            proxy_added = False
            for k in range(location_start + 1, location_end + 1):
                if 'proxy_pass' in lines[k]:
                    result_lines.append(f'        proxy_pass http://127.0.0.1:{target_port};')
                    proxy_added = True
                elif not proxy_added and '}' in lines[k]:
                    result_lines.append(f'        proxy_pass http://127.0.0.1:{target_port};')
                    result_lines.append('        proxy_http_version 1.1;')
                    result_lines.append('        proxy_set_header Upgrade $http_upgrade;')
                    result_lines.append('        proxy_set_header Connection "upgrade";')
                    result_lines.append('        proxy_set_header Host $host;')
                    result_lines.append('        proxy_set_header X-Real-IP $remote_addr;')
                    result_lines.append('        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;')
                    result_lines.append('        proxy_set_header X-Forwarded-Proto $scheme;')
                    result_lines.append(lines[k])
                    proxy_added = True
                else:
                    result_lines.append(lines[k])
            
            i = location_end + 1
            continue
    
    # Server block sonu
    if in_server_block and line.strip() == '}':
        in_server_block = False
        in_dugunkarem_block = False
        result_lines.append(line)
        i += 1
        continue
    
    result_lines.append(line)
    i += 1

content = '\n'.join(result_lines)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# 5. Nginx test ve reload
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

# 6. Kontrol
echo ""
echo -e "${YELLOW}🔍 dugunkarem.com server block'ları kontrol ediliyor...${NC}"
if sudo grep -A 5 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | grep -q "proxy_pass.*127.0.0.1:${TARGET_PORT}"; then
    echo -e "${GREEN}✅ dugunkarem.com port ${TARGET_PORT}'a yönlendiriliyor${NC}"
else
    echo -e "${RED}❌ dugunkarem.com port ${TARGET_PORT}'a yönlendirilmiyor!${NC}"
fi

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"

