#!/bin/bash

# 502 Bad Gateway hatasını agresif şekilde çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
NGINX_CONFIG_FIKIRTEPE="/etc/nginx/sites-available/fikirtepetekelpaket"
TARGET_PORT=3040

echo -e "${YELLOW}🔧 502 Bad Gateway hatası agresif şekilde çözülüyor...${NC}"

# 1. fikirtepetekelpaket.com config'ini tamamen devre dışı bırak
echo -e "${YELLOW}🛑 fikirtepetekelpaket.com config tamamen devre dışı bırakılıyor...${NC}"

# sites-enabled'den kaldır
if [ -L "/etc/nginx/sites-enabled/fikirtepetekelpaket" ]; then
    sudo rm /etc/nginx/sites-enabled/fikirtepetekelpaket
    echo -e "${GREEN}✅ fikirtepetekelpaket.com config sites-enabled'den kaldırıldı${NC}"
fi

# Config dosyasını yedekle ve içeriğini temizle
if [ -f "$NGINX_CONFIG_FIKIRTEPE" ]; then
    sudo cp "$NGINX_CONFIG_FIKIRTEPE" "${NGINX_CONFIG_FIKIRTEPE}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Tüm server block'larını yorum satırına al
    sudo python3 << PYEOF
config_file = "$NGINX_CONFIG_FIKIRTEPE"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Tüm satırları yorum satırına al
lines = content.split('\n')
result_lines = []
for line in lines:
    if line.strip() and not line.strip().startswith('#'):
        result_lines.append('# ' + line)
    else:
        result_lines.append(line)

content = '\n'.join(result_lines)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config devre dışı bırakıldı")
PYEOF
    
    echo -e "${GREEN}✅ fikirtepetekelpaket.com config devre dışı bırakıldı${NC}"
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

# 2. fikirtepetekelpaket.com server block'larını tamamen yorum satırına al
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
    
    # Server block sonu
    if in_server_block and line.strip() == '}':
        if in_fikirtepe_block:
            # Bu block'u yorum satırına al
            for j in range(block_start, i + 1):
                if not lines[j].strip().startswith('#'):
                    result_lines.append('    # ' + lines[j])
                else:
                    result_lines.append(lines[j])
        else:
            result_lines.append(line)
        in_server_block = False
        in_fikirtepe_block = False
        block_start = -1
        i += 1
        continue
    
    # Normal satırlar
    if not in_fikirtepe_block:
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

# 4. Aktif server block'ları kontrol et
echo ""
echo -e "${YELLOW}🔍 Aktif server block'lar kontrol ediliyor...${NC}"

# dugunkarem.com için hangi server block kullanılıyor?
echo -e "${YELLOW}📋 dugunkarem.com için aktif server block:${NC}"
sudo nginx -T 2>/dev/null | grep -B 5 -A 10 "server_name.*dugunkarem.com" | head -15

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"

