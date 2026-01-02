#!/bin/bash

# 502 Bad Gateway hatasını tamamen çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_PORT=3040
APP_NAME="foto-ugur-app"
APP_DIR="$HOME/premiumfoto"
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 502 Bad Gateway hatası çözülüyor...${NC}"

# 1. PM2 durumu kontrol et
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 2. foto-ugur-app çalışıyor mu?
if ! pm2 list | grep -q "${APP_NAME}.*online"; then
    echo -e "${YELLOW}⚠️  ${APP_NAME} çalışmıyor, başlatılıyor...${NC}"
    cd "$APP_DIR"
    pm2 stop "${APP_NAME}" || true
    pm2 delete "${APP_NAME}" || true
    sleep 2
    
    # Port 3040'ı temizle
    sudo fuser -k ${APP_PORT}/tcp 2>/dev/null || true
    sudo lsof -ti:${APP_PORT} | xargs sudo kill -9 2>/dev/null || true
    sleep 2
    
    # Başlat
    pm2 start npm --name "${APP_NAME}" -- start
    sleep 5
fi

# 3. Port 3040 kontrolü
echo -e "${YELLOW}🔍 Port ${APP_PORT} kontrol ediliyor...${NC}"
if ! sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${RED}❌ Port ${APP_PORT} dinlenmiyor!${NC}"
    echo -e "${YELLOW}💡 Logları kontrol edin:${NC}"
    pm2 logs "${APP_NAME}" --lines 20
    exit 1
else
    echo -e "${GREEN}✅ Port ${APP_PORT} dinleniyor${NC}"
    sudo lsof -i:${APP_PORT} | head -2
fi

# 4. Localhost test
echo -e "${YELLOW}🧪 Localhost test ediliyor...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT} || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Localhost çalışıyor! (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Localhost yanıt vermiyor! (HTTP $HTTP_CODE)${NC}"
    echo -e "${YELLOW}💡 Logları kontrol edin:${NC}"
    pm2 logs "${APP_NAME}" --lines 20
    exit 1
fi

# 5. Nginx config kontrolü
echo -e "${YELLOW}📝 Nginx config kontrol ediliyor...${NC}"

if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
    exit 1
fi

# Yedek al
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# dugunkarem.com ve dugunkarem.com.tr için proxy_pass kontrolü
echo -e "${YELLOW}🔍 dugunkarem.com proxy_pass kontrol ediliyor...${NC}"

# Python ile config düzeltme
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $APP_PORT
domains = ["dugunkarem.com", "dugunkarem.com.tr", "fotougur.com.tr"]

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Önce tüm yanlış port'ları düzelt
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:3001',
    f'proxy_pass http://127.0.0.1:{target_port}',
    content
)

# dugunkarem.com ve dugunkarem.com.tr için server block'ları bul
lines = content.split('\n')
result_lines = []
i = 0
in_target_server_block = False
in_server_block = False
block_start = -1

while i < len(lines):
    line = lines[i]
    
    # Server block başlangıcı
    if 'server {' in line or 'server{' in line:
        in_server_block = True
        block_start = i
        in_target_server_block = False
    
    # Server name kontrolü
    if in_server_block and 'server_name' in line:
        for domain in domains:
            if domain in line:
                in_target_server_block = True
                break
    
    # Location / bloğu
    if in_target_server_block and 'location /' in line and '{' in line:
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
        in_target_server_block = False
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

# 6. Nginx test ve reload
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

# 7. Domain testleri
echo ""
echo -e "${YELLOW}🧪 Domain testleri yapılıyor...${NC}"
for domain in "dugunkarem.com" "dugunkarem.com.tr" "fotougur.com.tr"; do
    echo -e "${YELLOW}📋 $domain:${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $domain" http://localhost || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}  ✅ Çalışıyor (HTTP $HTTP_CODE)${NC}"
    else
        echo -e "${YELLOW}  ⚠️  HTTP $HTTP_CODE${NC}"
    fi
done

# 8. Nginx error log kontrolü
echo ""
echo -e "${YELLOW}📋 Nginx error log (son 5 satır):${NC}"
sudo tail -5 /var/log/nginx/error.log || echo "Log okunamadı"

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol komutları:${NC}"
echo "   pm2 status ${APP_NAME}"
echo "   sudo lsof -i:${APP_PORT}"
echo "   curl -I http://localhost:${APP_PORT}"
echo "   sudo tail -20 /var/log/nginx/error.log"

