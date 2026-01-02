#!/bin/bash

# Port 3040 çalışıyor, sadece 502 scriptini çalıştır

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="$HOME/premiumfoto"
TARGET_PORT=3040

echo -e "${BLUE}🔧 502 hatası çözülüyor (Port ${TARGET_PORT} çalışıyor)...${NC}"
echo ""

cd "$APP_DIR"

# 1. Port kontrolü (curl ile)
echo -e "${YELLOW}1️⃣ Port ${TARGET_PORT} kontrol ediliyor...${NC}"
if curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:${TARGET_PORT} | grep -q "200"; then
    echo -e "${GREEN}✅ Port ${TARGET_PORT} çalışıyor!${NC}"
else
    echo -e "${RED}❌ Port ${TARGET_PORT} çalışmıyor!${NC}"
    echo -e "${YELLOW}💡 PM2'yi kontrol edin: pm2 status${NC}"
    exit 1
fi
echo ""

# 2. 502 scriptini çalıştır
echo -e "${YELLOW}2️⃣ 502 hatası çözülüyor...${NC}"
if [ -f "scripts/fix-502-dugunkarem-final.sh" ]; then
    sudo bash scripts/fix-502-dugunkarem-final.sh
else
    echo -e "${RED}❌ fix-502-dugunkarem-final.sh bulunamadı!${NC}"
    exit 1
fi

# 3. Nginx test
echo ""
echo -e "${YELLOW}3️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

# 4. Domain testleri
echo ""
echo -e "${YELLOW}4️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr")
for domain in "${DOMAINS[@]}"; do
    echo -e "${YELLOW}   Test ediliyor: https://${domain}${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 https://${domain} 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}   ✅ ${domain}: HTTP ${HTTP_CODE}${NC}"
    else
        echo -e "${RED}   ❌ ${domain}: HTTP ${HTTP_CODE}${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"
echo "   pm2 status"
echo "   sudo nginx -t"

