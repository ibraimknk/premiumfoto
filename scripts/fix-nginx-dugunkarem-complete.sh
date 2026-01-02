#!/bin/bash

# dugunkarem.com 502 hatasını tamamen çöz - agresif versiyon

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
NGINX_CONFIG_FIKIRTEPE="/etc/nginx/sites-available/fikirtepetekelpaket"
TARGET_PORT=3040

echo -e "${YELLOW}🔧 dugunkarem.com 502 hatası tamamen çözülüyor...${NC}"

# 1. Tüm Nginx config dosyalarını bul
echo -e "${YELLOW}📝 Tüm Nginx config dosyaları kontrol ediliyor...${NC}"

# fikirtepetekelpaket.com config'ini devre dışı bırak
if [ -f "$NGINX_CONFIG_FIKIRTEPE" ]; then
    echo -e "${YELLOW}🛑 fikirtepetekelpaket.com config devre dışı bırakılıyor...${NC}"
    if [ -L "/etc/nginx/sites-enabled/fikirtepetekelpaket" ]; then
        sudo rm /etc/nginx/sites-enabled/fikirtepetekelpaket
        echo -e "${GREEN}✅ fikirtepetekelpaket.com config devre dışı bırakıldı${NC}"
    fi
fi

# 2. foto-ugur config'inde dugunkarem.com için server block'ları kontrol et
echo -e "${YELLOW}📝 foto-ugur config güncelleniyor...${NC}"

if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
    exit 1
fi

# Yedek al
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# Python ile agresif düzeltme
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Tüm dugunkarem.com ve dugunkarem.com.tr için proxy_pass'leri port 3040'a çevir
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:3001',
    f'proxy_pass http://127.0.0.1:{target_port}',
    content
)

# 2. fikirtepetekelpaket.com server block'larından dugunkarem.com ve dugunkarem.com.tr'yi kaldır
lines = content.split('\n')
result_lines = []
i = 0
in_fikirtepe_block = False
in_server_block = False
block_start = -1

while i < len(lines):
    line = lines[i]
    
    # Server block başlangıcı
    if 'server {' in line or 'server{' in line:
        in_server_block = True
        block_start = i
        in_fikirtepe_block = False
    
    # Server name kontrolü
    if in_server_block and 'server_name' in line:
        # fikirtepetekelpaket.com içeren block mu?
        if 'fikirtepetekelpaket.com' in line:
            in_fikirtepe_block = True
            # dugunkarem.com ve dugunkarem.com.tr'yi server_name'den kaldır
            if 'dugunkarem.com' in line or 'dugunkarem.com.tr' in line:
                line = re.sub(r'\s+dugunkarem\.com(\s|;|$)', '', line)
                line = re.sub(r'\s+dugunkarem\.com\.tr(\s|;|$)', '', line)
                line = re.sub(r'\s+www\.dugunkarem\.com(\s|;|$)', '', line)
                line = re.sub(r'\s+www\.dugunkarem\.com\.tr(\s|;|$)', '', line)
    
    # Server block sonu
    if in_server_block and line.strip() == '}':
        in_server_block = False
        in_fikirtepe_block = False
        block_start = -1
        result_lines.append(line)
        i += 1
        continue
    
    # Normal satırlar
    result_lines.append(line)
    i += 1

content = '\n'.join(result_lines)

# 3. dugunkarem.com ve dugunkarem.com.tr için server block'ları bul ve proxy_pass'i kontrol et
lines = content.split('\n')
result_lines = []
i = 0
in_dugunkarem_block = False
in_server_block = False
block_start = -1

while i < len(lines):
    line = lines[i]
    
    # Server block başlangıcı
    if 'server {' in line or 'server{' in line:
        in_server_block = True
        block_start = i
        in_dugunkarem_block = False
    
    # Server name kontrolü
    if in_server_block and 'server_name' in line:
        # dugunkarem.com veya dugunkarem.com.tr içeren block mu?
        if 'dugunkarem.com' in line or 'dugunkarem.com.tr' in line:
            in_dugunkarem_block = True
    
    # Location / bloğu
    if in_dugunkarem_block and 'location /' in line and '{' in line:
        # Location bloğunu kontrol et
        location_start = i
        location_end = i
        brace_count = 0
        
        # Location bloğunun sonunu bul
        for j in range(i, len(lines)):
            if '{' in lines[j]:
                brace_count += lines[j].count('{')
            if '}' in lines[j]:
                brace_count -= lines[j].count('}')
            if brace_count == 0 and '}' in lines[j]:
                location_end = j
                break
        
        # Location bloğunu kontrol et
        location_block = '\n'.join(lines[location_start:location_end+1])
        
        # proxy_pass kontrolü
        if f'proxy_pass http://127.0.0.1:{target_port}' not in location_block:
            # Location bloğunu düzelt
            result_lines.append(lines[location_start])
            
            proxy_added = False
            for k in range(location_start + 1, location_end + 1):
                if 'proxy_pass' in lines[k]:
                    # Mevcut proxy_pass'i düzelt
                    result_lines.append(f'        proxy_pass http://127.0.0.1:{target_port};')
                    proxy_added = True
                elif not proxy_added and '}' in lines[k]:
                    # proxy_pass ekle
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
        block_start = -1
        result_lines.append(line)
        i += 1
        continue
    
    # Normal satırlar
    result_lines.append(line)
    i += 1

content = '\n'.join(result_lines)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# 3. Nginx test ve reload
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

# 4. Kontrol
echo ""
echo -e "${YELLOW}🔍 Kontrol ediliyor...${NC}"

# fikirtepetekelpaket.com config'inde dugunkarem var mı?
if [ -f "$NGINX_CONFIG_FIKIRTEPE" ]; then
    if sudo grep -q "dugunkarem.com" "$NGINX_CONFIG_FIKIRTEPE" 2>/dev/null; then
        echo -e "${RED}❌ fikirtepetekelpaket.com config'de hala dugunkarem.com var!${NC}"
    else
        echo -e "${GREEN}✅ fikirtepetekelpaket.com config'de dugunkarem.com yok${NC}"
    fi
fi

# foto-ugur config'inde dugunkarem.com proxy_pass kontrolü
if sudo grep -A 10 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | grep -q "proxy_pass.*127.0.0.1:${TARGET_PORT}"; then
    echo -e "${GREEN}✅ dugunkarem.com port ${TARGET_PORT}'a yönlendiriliyor${NC}"
else
    echo -e "${RED}❌ dugunkarem.com port ${TARGET_PORT}'a yönlendirilmiyor!${NC}"
fi

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"

