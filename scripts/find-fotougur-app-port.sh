#!/bin/bash

# fotougur-app'in hangi portta çalıştığını bul

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 fotougur-app port aranıyor...${NC}"
echo ""

# 1. PM2'deki tüm uygulamaları listele
echo -e "${YELLOW}1️⃣ PM2 uygulamaları:${NC}"
pm2 list
echo ""

# 2. PM2'deki tüm uygulamaların detaylarını göster
echo -e "${YELLOW}2️⃣ PM2 uygulama detayları:${NC}"
pm2 jlist | jq -r '.[] | "\(.name) - Port: \(.pm2_env.PORT // "belirtilmemiş") - Status: \(.pm2_env.status) - Script: \(.pm2_env.script) - Args: \(.pm2_env.args // "yok")"' 2>/dev/null || pm2 describe all
echo ""

# 3. Tüm aktif portları kontrol et
echo -e "${YELLOW}3️⃣ Aktif portlar (3000-3100 arası):${NC}"
for port in {3000..3100}; do
    if sudo lsof -i:${port} > /dev/null 2>&1; then
        PROCESS=$(sudo lsof -i:${port} | grep LISTEN | head -1 | awk '{print $1, $2, $9}')
        echo -e "${GREEN}   Port ${port}: ${PROCESS}${NC}"
    fi
done
echo ""

# 4. Node.js process'lerini kontrol et
echo -e "${YELLOW}4️⃣ Node.js process'leri:${NC}"
ps aux | grep -E "node|next|npm" | grep -v grep | while read line; do
    PID=$(echo $line | awk '{print $2}')
    CMD=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
    echo -e "${YELLOW}   PID: ${PID}${NC}"
    echo -e "${YELLOW}   CMD: ${CMD}${NC}"
    
    # Bu process'in dinlediği portları bul
    if sudo lsof -p ${PID} 2>/dev/null | grep -q LISTEN; then
        PORTS=$(sudo lsof -p ${PID} 2>/dev/null | grep LISTEN | awk '{print $9}' | cut -d: -f2 | sort -u)
        echo -e "${GREEN}   Dinlenen portlar: ${PORTS}${NC}"
    fi
    echo ""
done

# 5. PM2 ecosystem dosyalarını kontrol et
echo -e "${YELLOW}5️⃣ PM2 ecosystem dosyaları:${NC}"
find ~ -name "ecosystem*.js" -o -name "ecosystem*.cjs" 2>/dev/null | while read config_file; do
    echo -e "${YELLOW}   📄 $config_file${NC}"
    if grep -q "foto" "$config_file" 2>/dev/null; then
        echo -e "${GREEN}      ✅ foto ile ilgili!${NC}"
        grep -E "name|PORT|port|script|args" "$config_file" | head -10
    fi
    echo ""
done

# 6. .env dosyalarını kontrol et
echo -e "${YELLOW}6️⃣ .env dosyalarındaki PORT ayarları:${NC}"
find ~/premiumfoto -name ".env*" 2>/dev/null | while read env_file; do
    echo -e "${YELLOW}   📄 $env_file${NC}"
    grep -E "PORT|port" "$env_file" 2>/dev/null || echo "   PORT ayarı bulunamadı"
    echo ""
done

# 7. Nginx config'lerinde proxy_pass'leri kontrol et
echo -e "${YELLOW}7️⃣ Nginx config'lerinde proxy_pass'ler:${NC}"
sudo grep -r "proxy_pass.*127.0.0.1" /etc/nginx/sites-available/ 2>/dev/null | while read line; do
    echo -e "${YELLOW}   $line${NC}"
done
echo ""

# 8. Özet
echo -e "${BLUE}📊 Özet:${NC}"
echo -e "${BLUE}================================${NC}"

# En olası portları göster
LIKELY_PORTS=(3040 3000 3001 3002 3003)
echo -e "${YELLOW}💡 Kontrol edilmesi gereken portlar:${NC}"
for port in "${LIKELY_PORTS[@]}"; do
    if sudo lsof -i:${port} > /dev/null 2>&1; then
        PROCESS=$(sudo lsof -i:${port} | grep LISTEN | head -1)
        echo -e "${GREEN}   ✅ Port ${port}: ${PROCESS}${NC}"
    else
        echo -e "${RED}   ❌ Port ${port}: Boş${NC}"
    fi
done

echo ""
echo -e "${YELLOW}💡 PM2 loglarını kontrol etmek için:${NC}"
echo "   pm2 logs foto-ugur-app --lines 50"
echo "   pm2 logs --lines 50"

