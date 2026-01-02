#!/bin/bash

# dugunkarem.com.tr'nin port 3040'a (premiumfoto) yönlendirildiğinden emin ol

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="dugunkarem.com.tr"
TARGET_PORT=3040
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 ${DOMAIN} yönlendirmesi düzeltiliyor...${NC}"

# 1. Tüm Nginx config'lerinde dugunkarem.com.tr'yi bul
echo -e "${YELLOW}🔍 Tüm config'lerde ${DOMAIN} aranıyor...${NC}"

CONFIG_FILES=$(sudo find /etc/nginx/sites-available -type f -name "*.com" 2>/dev/null)

for config in $CONFIG_FILES; do
    if sudo grep -q "${DOMAIN}" "$config" 2>/dev/null; then
        echo -e "${YELLOW}📝 Bulundu: $config${NC}"
        echo -e "${YELLOW}   İçerik:${NC}"
        sudo grep -n "${DOMAIN}" "$config" | head -5
    fi
done

# 2. foto-ugur config'inde dugunkarem.com.tr kontrolü ve düzeltme
echo -e "${YELLOW}📝 foto-ugur config kontrol ediliyor...${NC}"

# Basit sed ile düzelt
if sudo grep -q "${DOMAIN}" "$FOTO_UGUR_CONFIG"; then
    echo -e "${GREEN}✅ ${DOMAIN} foto-ugur config'inde mevcut${NC}"
    
    # proxy_pass port'unu kontrol et ve düzelt
    if sudo grep -A 5 "${DOMAIN}" "$FOTO_UGUR_CONFIG" | grep -q "proxy_pass.*:${TARGET_PORT}"; then
        echo -e "${GREEN}✅ ${DOMAIN} zaten port ${TARGET_PORT}'a yönlendiriliyor${NC}"
    else
        echo -e "${YELLOW}⚠️  ${DOMAIN} proxy_pass port'u düzeltiliyor...${NC}"
        # Tüm proxy_pass satırlarını 3040'a yönlendir (foto-ugur config'inde)
        sudo sed -i "s|proxy_pass http://[^:]*:[0-9]*;|proxy_pass http://127.0.0.1:${TARGET_PORT};|g" "$FOTO_UGUR_CONFIG"
        echo -e "${GREEN}✅ Proxy pass port'u düzeltildi${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  ${DOMAIN} foto-ugur config'inde bulunamadı, ekleniyor...${NC}"
    
    # server_name satırına ekle
    sudo sed -i "s|server_name\(.*\)fotougur.com.tr\(.*\);|server_name\1fotougur.com.tr\2 ${DOMAIN} www.${DOMAIN};|g" "$FOTO_UGUR_CONFIG"
    echo -e "${GREEN}✅ ${DOMAIN} eklendi${NC}"
fi

# 3. Diğer config'lerden dugunkarem.com.tr'yi kaldır (foto-ugur ve fikirtepetekelpaket.com hariç)
echo -e "${YELLOW}🔧 Diğer config'lerden ${DOMAIN} kaldırılıyor...${NC}"

for config in $CONFIG_FILES; do
    if [ "$config" != "$FOTO_UGUR_CONFIG" ] && [ "$config" != "/etc/nginx/sites-available/fikirtepetekelpaket.com" ]; then
        if sudo grep -q "${DOMAIN}" "$config" 2>/dev/null; then
            echo -e "${YELLOW}🗑️  ${DOMAIN} kaldırılıyor: $config${NC}"
            # Basit sed ile kaldır
            sudo sed -i "s/\b${DOMAIN}\b//g" "$config"
            sudo sed -i "s/\bwww\.${DOMAIN}\b//g" "$config"
            sudo sed -i "s/  */ /g" "$config"  # Çoklu boşlukları temizle
            echo -e "${GREEN}✅ ${DOMAIN} kaldırıldı: $config${NC}"
        fi
    fi
done

# 4. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ ${DOMAIN} yönlendirmesi düzeltildi!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol:${NC}"
echo "   curl -I https://${DOMAIN}"
echo "   sudo cat ${FOTO_UGUR_CONFIG} | grep -A 5 '${DOMAIN}'"

