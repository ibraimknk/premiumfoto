#!/bin/bash

# dugunkarem.com, dugunkarem.com.tr ve fotougur.com.tr'yi port 3040'a yönlendir

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${YELLOW}🔧 Nginx config'inde domain'ler port ${TARGET_PORT}'a yönlendiriliyor...${NC}"

# 1. Port 3040'ın çalıştığını kontrol et
echo -e "${YELLOW}🔍 Port ${TARGET_PORT} kontrol ediliyor...${NC}"
if ! sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
    echo -e "${RED}❌ Port ${TARGET_PORT} dinlenmiyor!${NC}"
    echo -e "${YELLOW}💡 Önce foto-ugur-app'i başlatın:${NC}"
    echo "   cd ~/premiumfoto"
    echo "   pm2 start npm --name foto-ugur-app -- start"
    exit 1
fi

echo -e "${GREEN}✅ Port ${TARGET_PORT} dinleniyor${NC}"
sudo lsof -i:${TARGET_PORT} | head -2

# 2. Nginx config kontrolü
if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
    exit 1
fi

# Yedek al
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# 3. Python ile config düzeltme
echo -e "${YELLOW}📝 Nginx config güncelleniyor...${NC}"

sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT
domains = ["dugunkarem.com", "dugunkarem.com.tr", "fotougur.com.tr"]

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
result_lines = []
i = 0
in_target_server_block = False
in_server_block = False
block_start = -1
server_name_found = False

while i < len(lines):
    line = lines[i]
    
    # Server block başlangıcı
    if 'server {' in line or 'server{' in line:
        in_server_block = True
        block_start = i
        server_name_found = False
        in_target_server_block = False
    
    # Server name kontrolü
    if in_server_block and 'server_name' in line:
        server_name_found = True
        # Hedef domain'lerden biri var mı?
        for domain in domains:
            if domain in line:
                in_target_server_block = True
                break
    
    # Location / bloğu
    if in_target_server_block and 'location /' in line and '{' in line:
        # Bu location bloğunu kontrol et ve düzelt
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
        if 'proxy_pass' not in location_block or f'127.0.0.1:{target_port}' not in location_block:
            # Location bloğunu düzelt
            result_lines.append(lines[location_start])
            
            # proxy_pass ekle veya düzelt
            proxy_added = False
            for k in range(location_start + 1, location_end + 1):
                if 'proxy_pass' in lines[k]:
                    # Mevcut proxy_pass'i düzelt
                    result_lines.append(f'        proxy_pass http://127.0.0.1:{target_port};')
                    proxy_added = True
                elif not proxy_added and '}' in lines[k] and brace_count == 1:
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
        if not in_target_server_block:
            result_lines.append(line)
        in_server_block = False
        in_target_server_block = False
        block_start = -1
        server_name_found = False
        i += 1
        continue
    
    # Normal satırlar
    if not in_target_server_block or ('location /' not in line and '{' not in line):
        result_lines.append(line)
    
    i += 1

content = '\n'.join(result_lines)

# Ayrıca, proxy_pass'leri kontrol et ve düzelt
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:[0-9]+;',
    f'proxy_pass http://127.0.0.1:{target_port};',
    content
)

# dugunkarem.com ve dugunkarem.com.tr için yanlış port varsa düzelt
for domain in ["dugunkarem.com", "dugunkarem.com.tr"]:
    # Bu domain'lerin server block'larında port 3001 varsa 3040'a çevir
    pattern = f'(server_name[^;]*{domain}[^;]*;.*?proxy_pass\\s+http://127\\.0\\.0\\.1:)3001'
    replacement = f'\\1{target_port}'
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# 4. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}💡 Yedek dosyadan geri yükleyin${NC}"
    exit 1
fi

# 5. Domain yönlendirmelerini kontrol et
echo ""
echo -e "${YELLOW}🔍 Domain yönlendirmeleri kontrol ediliyor...${NC}"
for domain in "dugunkarem.com" "dugunkarem.com.tr" "fotougur.com.tr"; do
    echo -e "${YELLOW}📋 $domain:${NC}"
    if sudo grep -A 10 "server_name.*$domain" "$NGINX_CONFIG" | grep -q "proxy_pass.*127.0.0.1:${TARGET_PORT}"; then
        echo -e "${GREEN}  ✅ Port ${TARGET_PORT}'a yönlendiriliyor${NC}"
    else
        echo -e "${RED}  ❌ Port ${TARGET_PORT}'a yönlendirilmiyor!${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I http://localhost:${TARGET_PORT}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"
echo "   curl -I https://fotougur.com.tr"
