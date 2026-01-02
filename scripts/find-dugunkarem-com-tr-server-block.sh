#!/bin/bash

# dugunkarem.com.tr'yi hangi server block yakalıyor bul

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="dugunkarem.com.tr"

echo -e "${YELLOW}🔍 ${DOMAIN} için aktif server block aranıyor...${NC}"

# Tüm Nginx config dosyalarını kontrol et
echo -e "${YELLOW}📋 Tüm config dosyalarında ${DOMAIN} aranıyor...${NC}"

CONFIG_FILES=$(sudo find /etc/nginx/sites-available -type f 2>/dev/null)

for config in $CONFIG_FILES; do
    if sudo grep -q "${DOMAIN}" "$config" 2>/dev/null; then
        echo -e "${YELLOW}📝 Bulundu: $config${NC}"
        echo -e "${YELLOW}   İlgili satırlar:${NC}"
        sudo grep -n "${DOMAIN}" "$config" | head -10
        echo ""
        
        # SSL server block'unu göster
        echo -e "${YELLOW}   SSL server block:${NC}"
        sudo awk '/server\s*\{/,/\}/' "$config" | grep -A 20 "${DOMAIN}" | grep -A 20 "listen.*443" | head -30 || echo "   SSL block bulunamadı"
        echo ""
    fi
done

# Nginx'in hangi server block'u seçeceğini test et
echo -e "${YELLOW}🔍 Nginx server block eşleştirme testi...${NC}"
sudo nginx -T 2>/dev/null | grep -A 30 "server_name.*${DOMAIN}" | head -40

