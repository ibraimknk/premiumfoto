#!/bin/bash

# aktas-market server.js port ayarını düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

AKTAS_DIR="/var/www/fikirtepetekelpaket.com"
APP_PORT=3001

echo -e "${YELLOW}🔧 aktas-market server.js port ayarı düzeltiliyor...${NC}"

if [ ! -f "$AKTAS_DIR/server.js" ]; then
    echo -e "${RED}❌ server.js dosyası bulunamadı: $AKTAS_DIR/server.js${NC}"
    exit 1
fi

echo -e "${GREEN}✅ server.js dosyası bulundu${NC}"

# server.js dosyasını yedekle
cp "$AKTAS_DIR/server.js" "$AKTAS_DIR/server.js.backup.$(date +%Y%m%d_%H%M%S)"

# server.js dosyasını oku
echo -e "${YELLOW}📝 server.js dosyası kontrol ediliyor...${NC}"

# Port'un nasıl okunduğunu kontrol et
if grep -q "process.env.PORT" "$AKTAS_DIR/server.js"; then
    echo -e "${GREEN}✅ server.js zaten process.env.PORT kullanıyor${NC}"
    
    # Ama belki de default port var, onu kontrol et
    if grep -q "process.env.PORT \|\| 3000" "$AKTAS_DIR/server.js"; then
        echo -e "${YELLOW}⚠️  Default port 3000 bulundu, ${APP_PORT} olarak güncelleniyor...${NC}"
        sed -i "s/process.env.PORT \|\| 3000/process.env.PORT || ${APP_PORT}/" "$AKTAS_DIR/server.js"
        echo -e "${GREEN}✅ Default port ${APP_PORT} olarak güncellendi${NC}"
    fi
elif grep -q "listen(3000" "$AKTAS_DIR/server.js"; then
    echo -e "${YELLOW}⚠️  Hardcoded port 3000 bulundu, environment variable kullanımına çevriliyor...${NC}"
    
    # listen(3000) veya listen(3000, ...) şeklinde olabilir
    # process.env.PORT || 3001 şeklinde değiştir
    sed -i "s/listen(3000/listen(process.env.PORT || ${APP_PORT}/" "$AKTAS_DIR/server.js"
    echo -e "${GREEN}✅ Port environment variable kullanımına çevrildi${NC}"
elif grep -q "listen(" "$AKTAS_DIR/server.js"; then
    echo -e "${YELLOW}📝 listen() bulundu, port kontrolü yapılıyor...${NC}"
    # listen() satırını göster
    grep -n "listen(" "$AKTAS_DIR/server.js" | head -1
else
    echo -e "${YELLOW}⚠️  listen() bulunamadı, manuel kontrol gerekli${NC}"
fi

# .env dosyasını kontrol et
cd "$AKTAS_DIR"
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 .env dosyası oluşturuluyor...${NC}"
    cat > .env << EOF
NODE_ENV=production
PORT=${APP_PORT}
EOF
else
    if grep -q "PORT=" .env; then
        sed -i "s/PORT=.*/PORT=${APP_PORT}/" .env
        echo -e "${GREEN}✅ .env dosyasında PORT=${APP_PORT} olarak güncellendi${NC}"
    else
        echo "PORT=${APP_PORT}" >> .env
        echo -e "${GREEN}✅ .env dosyasına PORT=${APP_PORT} eklendi${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Port ayarları güncellendi!${NC}"
echo ""
echo -e "${YELLOW}📋 Sonraki adımlar:${NC}"
echo "   1. PM2'yi durdur: pm2 stop aktas-market && pm2 delete aktas-market"
echo "   2. Port 3001'i temizle: sudo fuser -k 3001/tcp"
echo "   3. PM2'yi tekrar başlat: pm2 start /var/www/fikirtepetekelpaket.com/ecosystem-aktas-market.config.cjs"
echo ""
echo -e "${YELLOW}💡 Veya otomatik düzeltme scriptini çalıştırın:${NC}"
echo "   bash scripts/fix-aktas-market-port-3001-force.sh"

