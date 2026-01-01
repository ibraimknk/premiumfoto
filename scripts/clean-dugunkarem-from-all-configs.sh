#!/bin/bash

# Tüm nginx config dosyalarından dugunkarem.com'u temizle (foto-ugur'daki özel block hariç)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🧹 Tüm config dosyalarından dugunkarem.com temizleniyor...${NC}"

# Tüm sites-available config dosyalarını kontrol et
for config in /etc/nginx/sites-available/*; do
    if [ -f "$config" ] && [ "$(basename $config)" != "foto-ugur" ]; then
        CONFIG_NAME=$(basename "$config")
        echo -e "${YELLOW}📝 $CONFIG_NAME kontrol ediliyor...${NC}"
        
        # dugunkarem.com içeriyor mu?
        if sudo grep -q "dugunkarem\.com" "$config"; then
            echo -e "${YELLOW}⚠️  $CONFIG_NAME içinde dugunkarem.com bulundu, temizleniyor...${NC}"
            
            # Yedekle
            sudo cp "$config" "${config}.backup.$(date +%Y%m%d_%H%M%S)"
            
            # dugunkarem.com ve dugunkarem.com.tr'yi kaldır
            sudo sed -i 's/dugunkarem\.com\.tr//g' "$config"
            sudo sed -i 's/www\.dugunkarem\.com\.tr//g' "$config"
            sudo sed -i 's/dugunkarem\.com//g' "$config"
            sudo sed -i 's/www\.dugunkarem\.com//g' "$config"
            
            # Çoklu boşlukları temizle
            sudo sed -i 's/server_name  */server_name /g' "$config"
            sudo sed -i 's/ ;/;/g' "$config"
            
            echo -e "${GREEN}✅ $CONFIG_NAME temizlendi${NC}"
        else
            echo -e "${GREEN}✅ $CONFIG_NAME temiz${NC}"
        fi
    fi
done

# foto-ugur config'ini kontrol et - sadece özel dugunkarem block'unda olmalı
echo ""
echo -e "${YELLOW}📝 foto-ugur config kontrol ediliyor...${NC}"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

# İlk server block'tan dugunkarem.com'u kaldır (eğer hala varsa)
if sudo grep -A 5 "listen 443 ssl" "$FOTO_UGUR_CONFIG" | grep -q "server_name.*fotougur.*dugunkarem"; then
    echo -e "${YELLOW}⚠️  foto-ugur config'indeki ilk server block'tan dugunkarem.com kaldırılıyor...${NC}"
    
    sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# İlk server block'tan dugunkarem.com'u kaldır (fotougur.com.tr içeren)
# server_name satırını bul ve dugunkarem.com'u kaldır
def remove_dugunkarem_from_first_block(match):
    full_match = match.group(0)
    # dugunkarem.com ve dugunkarem.com.tr'yi kaldır
    cleaned = re.sub(r'\s*dugunkarem\.com\.tr\s*', ' ', full_match)
    cleaned = re.sub(r'\s*dugunkarem\.com\s*', ' ', cleaned)
    cleaned = re.sub(r'\s+', ' ', cleaned)
    return cleaned

# İlk server block'u bul (fotougur.com.tr içeren, 443 portu olan)
pattern = r'(server\s*\{[^}]*server_name\s+[^;]*fotougur\.com\.tr[^;]*)(dugunkarem[^;]*)(;[^}]*listen\s+443[^}]*\})'
content = re.sub(pattern, lambda m: m.group(1) + m.group(3), content, flags=re.DOTALL, count=1)

# 80 portu için de
pattern = r'(server\s*\{[^}]*server_name\s+[^;]*fotougur\.com\.tr[^;]*)(dugunkarem[^;]*)(;[^}]*listen\s+80[^}]*\})'
content = re.sub(pattern, lambda m: m.group(1) + m.group(3), content, flags=re.DOTALL, count=1)

# server_name satırlarını temizle
content = re.sub(r'server_name\s+([^;]*dugunkarem[^;]*);', lambda m: 'server_name ' + re.sub(r'\s*dugunkarem\.com\.tr\s*|\s*dugunkarem\.com\s*', ' ', m.group(1)).strip() + ';', content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ foto-ugur config'inden ilk server block temizlendi")
PYEOF
fi

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
echo -e "${GREEN}✅ Tüm config dosyaları temizlendi!${NC}"
echo -e "${YELLOW}📋 dugunkarem.com artık sadece foto-ugur config'indeki özel server block'unda${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -subject"

