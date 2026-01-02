#!/bin/bash

# Nginx config'i sıfırdan yeniden oluştur (duplicate listen temizleme ile)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_DIR="/etc/nginx/sites-available/backups"

echo -e "${BLUE}🔧 Nginx config sıfırdan yeniden oluşturuluyor...${NC}"
echo ""

# 1. Yedek al
echo -e "${YELLOW}1️⃣ Yedek alınıyor...${NC}"
sudo mkdir -p "$BACKUP_DIR"
sudo cp "$NGINX_CONFIG" "${BACKUP_DIR}/foto-ugur.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Yedek alındı${NC}"
echo ""

# 2. Mevcut config'den sadece fotougur.com.tr block'larını düzgün bir şekilde al ve temizle
echo -e "${YELLOW}2️⃣ Mevcut config'den fotougur.com.tr block'ları alınıyor ve temizleniyor...${NC}"
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Server block'larını düzgün bir şekilde parse et
fotougur_blocks = []
i = 0
in_server_block = False
server_block_lines = []
brace_count = 0

while i < len(lines):
    line = lines[i]
    
    if 'server {' in line:
        in_server_block = True
        server_block_lines = [line]
        brace_count = 1
        i += 1
        continue
    
    if in_server_block:
        server_block_lines.append(line)
        if '{' in line:
            brace_count += line.count('{')
        if '}' in line:
            brace_count -= line.count('}')
        
        if brace_count == 0:
            # Server block tamamlandı
            block_content = ''.join(server_block_lines)
            # Eğer fotougur.com.tr içeriyorsa ve dugunkarem içermiyorsa
            if 'fotougur.com.tr' in block_content.lower() and 'dugunkarem' not in block_content.lower():
                # Duplicate listen satırlarını temizle
                block_lines = block_content.split('\n')
                cleaned_lines = []
                listen_443_found = False
                listen_80_found = False
                
                for bline in block_lines:
                    # listen 443 satırlarını kontrol et
                    if re.match(r'^\s*listen\s+443', bline):
                        if not listen_443_found:
                            cleaned_lines.append(bline)
                            listen_443_found = True
                        # Duplicate'leri atla
                        continue
                    # listen 80 satırlarını kontrol et
                    elif re.match(r'^\s*listen\s+80', bline):
                        if not listen_80_found:
                            cleaned_lines.append(bline)
                            listen_80_found = True
                        # Duplicate'leri atla
                        continue
                    else:
                        cleaned_lines.append(bline)
                
                cleaned_block = '\n'.join(cleaned_lines)
                fotougur_blocks.append(cleaned_block)
            in_server_block = False
            server_block_lines = []
    
    i += 1

print(f"✅ {len(fotougur_blocks)} fotougur.com.tr block'u bulundu ve temizlendi")
PYEOF

# 3. Yeni config dosyasını oluştur
echo -e "${YELLOW}3️⃣ Yeni config dosyası oluşturuluyor...${NC}"
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

# dugunkarem.com block'ları
dugunkarem_blocks = '''# dugunkarem.com HTTP -> HTTPS redirect
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

# Mevcut config'den fotougur.com.tr block'larını düzgün bir şekilde al ve temizle
with open(config_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

fotougur_blocks = []
i = 0
in_server_block = False
server_block_lines = []
brace_count = 0

while i < len(lines):
    line = lines[i]
    
    if 'server {' in line:
        in_server_block = True
        server_block_lines = [line]
        brace_count = 1
        i += 1
        continue
    
    if in_server_block:
        server_block_lines.append(line)
        if '{' in line:
            brace_count += line.count('{')
        if '}' in line:
            brace_count -= line.count('}')
        
        if brace_count == 0:
            # Server block tamamlandı
            block_content = ''.join(server_block_lines)
            # Eğer fotougur.com.tr içeriyorsa ve dugunkarem içermiyorsa
            if 'fotougur.com.tr' in block_content.lower() and 'dugunkarem' not in block_content.lower():
                # Duplicate listen satırlarını temizle
                block_lines = block_content.split('\n')
                cleaned_lines = []
                listen_443_found = False
                listen_80_found = False
                listen_ipv6_443_found = False
                listen_ipv6_80_found = False
                
                for bline in block_lines:
                    # listen 443 satırlarını kontrol et
                    if re.match(r'^\s*listen\s+443', bline):
                        if not listen_443_found:
                            cleaned_lines.append(bline)
                            listen_443_found = True
                        # Duplicate'leri atla
                        continue
                    # listen [::]:443 satırlarını kontrol et
                    elif re.match(r'^\s*listen\s+\[::\]:443', bline):
                        if not listen_ipv6_443_found:
                            cleaned_lines.append(bline)
                            listen_ipv6_443_found = True
                        # Duplicate'leri atla
                        continue
                    # listen 80 satırlarını kontrol et
                    elif re.match(r'^\s*listen\s+80', bline):
                        if not listen_80_found:
                            cleaned_lines.append(bline)
                            listen_80_found = True
                        # Duplicate'leri atla
                        continue
                    # listen [::]:80 satırlarını kontrol et
                    elif re.match(r'^\s*listen\s+\[::\]:80', bline):
                        if not listen_ipv6_80_found:
                            cleaned_lines.append(bline)
                            listen_ipv6_80_found = True
                        # Duplicate'leri atla
                        continue
                    else:
                        cleaned_lines.append(bline)
                
                cleaned_block = '\n'.join(cleaned_lines)
                fotougur_blocks.append(cleaned_block)
            in_server_block = False
            server_block_lines = []
    
    i += 1

# Yeni config'i oluştur
new_config = dugunkarem_blocks

if fotougur_blocks:
    new_config += "\n# fotougur.com.tr block'ları\n"
    for block in fotougur_blocks:
        new_config += block + "\n"

# Config dosyasını yaz
with open(config_file, 'w', encoding='utf-8') as f:
    f.write(new_config)

print(f"✅ Yeni config oluşturuldu ({len(fotougur_blocks)} fotougur.com.tr block'u eklendi)")
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
    sudo nginx -t 2>&1 | head -20
    echo ""
    echo -e "${YELLOW}💡 Satır 95-105:${NC}"
    sudo sed -n '95,105p' "$NGINX_CONFIG"
    echo ""
    echo -e "${YELLOW}💡 Config dosyasının ilk 30 satırı:${NC}"
    sudo head -30 "$NGINX_CONFIG"
    exit 1
fi

# 5. Test
echo ""
echo -e "${YELLOW}5️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr" "fotougur.com.tr")
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
echo -e "${YELLOW}📋 Config dosyası: ${NGINX_CONFIG}${NC}"

