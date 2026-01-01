#!/bin/bash

# dugunkarem.com için final düzeltme - tüm aktif config'leri kontrol et

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Aktif config dosyalarında dugunkarem.com aranıyor...${NC}"

# sites-enabled'daki tüm config'leri kontrol et
echo ""
echo -e "${YELLOW}📋 sites-enabled'daki config'ler:${NC}"
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        CONFIG_NAME=$(basename "$config")
        echo ""
        echo "--- $CONFIG_NAME ---"
        
        # dugunkarem.com içeriyor mu?
        if sudo grep -q "dugunkarem\.com" "$config"; then
            echo -e "${RED}❌ $CONFIG_NAME içinde dugunkarem.com bulundu!${NC}"
            echo "Server block'ları:"
            sudo grep -B 5 -A 15 "dugunkarem\.com" "$config" | head -25
            
            # Eğer foto-ugur değilse, kaldır
            if [ "$CONFIG_NAME" != "foto-ugur" ]; then
                echo -e "${YELLOW}⚠️  $CONFIG_NAME'den dugunkarem.com kaldırılıyor...${NC}"
                sudo sed -i 's/dugunkarem\.com\.tr//g' "$config"
                sudo sed -i 's/www\.dugunkarem\.com\.tr//g' "$config"
                sudo sed -i 's/dugunkarem\.com//g' "$config"
                sudo sed -i 's/www\.dugunkarem\.com//g' "$config"
                sudo sed -i 's/server_name  */server_name /g' "$config"
                sudo sed -i 's/ ;/;/g' "$config"
                echo -e "${GREEN}✅ $CONFIG_NAME temizlendi${NC}"
            fi
        else
            echo -e "${GREEN}✅ $CONFIG_NAME temiz${NC}"
        fi
    fi
done

# foto-ugur config'ini özel kontrol et
echo ""
echo -e "${YELLOW}📝 foto-ugur config detaylı kontrol:${NC}"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

# Tüm server block'larını listele
echo ""
echo "Server block'ları:"
sudo grep -n "server {" "$FOTO_UGUR_CONFIG" | head -10

# dugunkarem.com için server block'u kontrol et
echo ""
echo "dugunkarem.com için server block:"
sudo grep -B 2 -A 20 "server_name.*dugunkarem\.com.*dugunkarem\.com\.tr" "$FOTO_UGUR_CONFIG" | head -25

# İlk server block'tan dugunkarem.com'u manuel kaldır
echo ""
echo -e "${YELLOW}📝 İlk server block'tan dugunkarem.com manuel kaldırılıyor...${NC}"

sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    lines = f.readlines()

# İlk server block'u bul ve dugunkarem.com'u kaldır
in_first_server = False
first_server_start = -1
first_server_end = -1

for i, line in enumerate(lines):
    if re.match(r'^\s*server\s*\{', line) and first_server_start == -1:
        in_first_server = True
        first_server_start = i
    elif in_first_server and re.match(r'^\s*\}', line):
        first_server_end = i
        break

if first_server_start != -1 and first_server_end != -1:
    # İlk server block içinde server_name satırını bul
    for i in range(first_server_start, first_server_end + 1):
        if 'server_name' in lines[i] and 'fotougur.com.tr' in lines[i]:
            # dugunkarem.com ve dugunkarem.com.tr'yi kaldır
            lines[i] = re.sub(r'\s*dugunkarem\.com\.tr\s*', ' ', lines[i])
            lines[i] = re.sub(r'\s*dugunkarem\.com\s*', ' ', lines[i])
            lines[i] = re.sub(r'\s+', ' ', lines[i])
            lines[i] = re.sub(r' ;', ';', lines[i])
            print(f"✅ Satır {i+1} temizlendi: {lines[i].strip()}")
            break

with open(config_file, 'w') as f:
    f.writelines(lines)

print("✅ İlk server block temizlendi")
PYEOF

# Nginx test
echo ""
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Final düzeltme tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -subject"

