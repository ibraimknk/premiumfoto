#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr 502/403 hatalarını düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 dugunkarem.com ve dugunkarem.com.tr hataları düzeltiliyor...${NC}"

# 1. PM2 durumu kontrol et
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# foto-ugur-app çalışıyor mu?
if ! pm2 list | grep -q "foto-ugur-app.*online"; then
    echo -e "${YELLOW}⚠️  foto-ugur-app çalışmıyor, başlatılıyor...${NC}"
    cd ~/premiumfoto
    pm2 restart foto-ugur-app --update-env || pm2 start npm --name "foto-ugur-app" -- start
    sleep 3
fi

# 2. Port 3040 kontrolü
echo -e "${YELLOW}🔍 Port 3040 kontrol ediliyor...${NC}"
if ! sudo lsof -i:3040 > /dev/null 2>&1; then
    echo -e "${RED}❌ Port 3040 dinlenmiyor!${NC}"
    echo -e "${YELLOW}💡 foto-ugur-app'i kontrol edin: pm2 logs foto-ugur-app${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Port 3040 dinleniyor${NC}"
    sudo lsof -i:3040 | head -2
fi

# 3. Nginx config kontrolü ve düzeltme
echo -e "${YELLOW}📝 Nginx config kontrol ediliyor...${NC}"

if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
    exit 1
fi

# Yedek al
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# dugunkarem.com ve dugunkarem.com.tr için server block'ları kontrol et
echo -e "${YELLOW}🔍 dugunkarem.com server block'ları kontrol ediliyor...${NC}"

# Python ile config düzeltme
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# dugunkarem.com ve dugunkarem.com.tr için server block'ları bul
lines = content.split('\n')
result_lines = []
i = 0
in_dugunkarem_block = False
in_server_block = False
block_start = -1
server_name_line = -1

while i < len(lines):
    line = lines[i]
    
    # Server block başlangıcı
    if 'server {' in line or 'server{' in line:
        in_server_block = True
        block_start = i
        server_name_line = -1
    
    # Server name kontrolü
    if in_server_block and 'server_name' in line:
        server_name_line = i
        if 'dugunkarem.com' in line or 'dugunkarem.com.tr' in line:
            in_dugunkarem_block = True
    
    # Server block sonu
    if in_server_block and line.strip() == '}':
        if in_dugunkarem_block:
            # dugunkarem block'u kontrol et ve düzelt
            block_lines = lines[block_start:i+1]
            block_content = '\n'.join(block_lines)
            
            # Eğer proxy_pass yoksa veya yanlışsa düzelt
            if 'proxy_pass http://127.0.0.1:3040' not in block_content:
                # proxy_pass ekle veya düzelt
                fixed_block = []
                location_found = False
                for bl in block_lines:
                    if 'location /' in bl and '{' in bl:
                        location_found = True
                        fixed_block.append(bl)
                    elif location_found and '}' in bl and not any('proxy_pass' in b for b in fixed_block[-10:]):
                        # proxy_pass ekle
                        fixed_block.append('        proxy_pass http://127.0.0.1:3040;')
                        fixed_block.append('        proxy_http_version 1.1;')
                        fixed_block.append('        proxy_set_header Upgrade \$http_upgrade;')
                        fixed_block.append('        proxy_set_header Connection "upgrade";')
                        fixed_block.append('        proxy_set_header Host \$host;')
                        fixed_block.append('        proxy_set_header X-Real-IP \$remote_addr;')
                        fixed_block.append('        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;')
                        fixed_block.append('        proxy_set_header X-Forwarded-Proto \$scheme;')
                        fixed_block.append(bl)
                        location_found = False
                    else:
                        fixed_block.append(bl)
                
                result_lines.extend(fixed_block)
            else:
                result_lines.extend(block_lines)
            
            in_dugunkarem_block = False
        else:
            result_lines.extend(lines[block_start:i+1])
        
        in_server_block = False
        block_start = -1
        server_name_line = -1
        i += 1
        continue
    
    # Normal satırlar
    if not in_server_block:
        result_lines.append(line)
    
    i += 1

content = '\n'.join(result_lines)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# 4. Static dosyalar için izin kontrolü
echo -e "${YELLOW}🔍 Static dosya izinleri kontrol ediliyor...${NC}"

# premiumfoto public dizini izinleri
if [ -d ~/premiumfoto/public ]; then
    sudo chown -R $USER:$USER ~/premiumfoto/public
    chmod -R 755 ~/premiumfoto/public
    echo -e "${GREEN}✅ premiumfoto/public izinleri düzeltildi${NC}"
fi

# 5. Nginx test ve reload
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

# 6. dugunkarem.com'un aktas-market'e yönlendirilmediğinden emin ol
echo -e "${YELLOW}🔍 dugunkarem.com yönlendirme kontrolü...${NC}"

# Eğer dugunkarem.com port 3001'e yönlendiriliyorsa, 3040'a çevir
if sudo grep -q "dugunkarem.com.*3001" "$NGINX_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  dugunkarem.com port 3001'e yönlendiriliyor, 3040'a çevriliyor...${NC}"
    sudo sed -i 's/127\.0\.0\.1:3001/127.0.0.1:3040/g' "$NGINX_CONFIG"
    sudo nginx -t && sudo systemctl reload nginx
    echo -e "${GREEN}✅ Yönlendirme düzeltildi${NC}"
fi

# 7. Son kontrol
echo ""
echo -e "${YELLOW}📊 Son durum:${NC}"
echo "PM2 durumu:"
pm2 status | grep -E "(foto-ugur-app|dugunkarem-app)"
echo ""
echo "Port 3040:"
sudo lsof -i:3040 | head -2 || echo "  Boş"
echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I http://localhost:3040"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

