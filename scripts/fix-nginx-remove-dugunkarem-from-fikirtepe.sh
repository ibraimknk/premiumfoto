#!/bin/bash

# fikirtepetekelpaket.com config'inden dugunkarem.com ve dugunkarem.com.tr'yi kaldır

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NGINX_CONFIGS=(
    "/etc/nginx/sites-available/foto-ugur"
    "/etc/nginx/sites-available/fikirtepetekelpaket"
)

echo -e "${YELLOW}🔧 fikirtepetekelpaket.com config'inden dugunkarem domain'leri kaldırılıyor...${NC}"

for config in "${NGINX_CONFIGS[@]}"; do
    if [ ! -f "$config" ]; then
        echo -e "${YELLOW}⚠️  Config bulunamadı: $config${NC}"
        continue
    fi
    
    echo -e "${YELLOW}📝 $config işleniyor...${NC}"
    
    # Yedek al
    sudo cp "$config" "${config}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Python ile config düzeltme
    sudo python3 << PYEOF
import re

config_file = "$config"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# fikirtepetekelpaket.com server block'larından dugunkarem.com ve dugunkarem.com.tr'yi kaldır
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
                # dugunkarem domain'lerini kaldır
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

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF
    
    echo -e "${GREEN}✅ $config güncellendi${NC}"
done

# Nginx test ve reload
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

# Kontrol
echo ""
echo -e "${YELLOW}🔍 Kontrol ediliyor...${NC}"
for config in "${NGINX_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        if sudo grep -q "fikirtepetekelpaket.com.*dugunkarem.com" "$config" 2>/dev/null; then
            echo -e "${RED}❌ $config'de hala dugunkarem.com var!${NC}"
        else
            echo -e "${GREEN}✅ $config'de dugunkarem.com kaldırıldı${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"
echo "   sudo tail -10 /var/log/nginx/error.log"

