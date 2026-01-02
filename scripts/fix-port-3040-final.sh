#!/bin/bash

# Port 3040'ı tamamen temizle ve başlat

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_PORT=3040
APP_NAME="foto-ugur-app"
APP_DIR="$HOME/premiumfoto"

echo -e "${YELLOW}🔧 Port ${APP_PORT} tamamen temizleniyor...${NC}"

# 1. PM2'de foto-ugur-app'i durdur
echo -e "${YELLOW}🛑 PM2'de ${APP_NAME} durduruluyor...${NC}"
if pm2 list | grep -q "${APP_NAME}"; then
    pm2 stop "${APP_NAME}" || true
    pm2 delete "${APP_NAME}" || true
    sleep 2
fi

# 2. Port 3040'ı kullanan TÜM process'leri bul ve durdur
echo -e "${YELLOW}🔍 Port ${APP_PORT} kullanan process'ler bulunuyor...${NC}"

# fuser ile process ID'leri bul
FUSER_OUTPUT=$(sudo fuser ${APP_PORT}/tcp 2>&1 || echo "")
if echo "$FUSER_OUTPUT" | grep -q "[0-9]"; then
    PIDS=$(echo "$FUSER_OUTPUT" | grep -o '[0-9]*' | sort -u)
    echo -e "${YELLOW}⚠️  fuser ile bulunan process ID'ler: $PIDS${NC}"
    for pid in $PIDS; do
        if [ ! -z "$pid" ] && [ "$pid" != "PID" ]; then
            echo -e "${YELLOW}   Process $pid durduruluyor...${NC}"
            sudo kill -9 $pid 2>/dev/null || true
        fi
    done
    sleep 2
fi

# lsof ile de kontrol et
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  lsof ile process'ler bulunuyor...${NC}"
    sudo lsof -ti:${APP_PORT} | while read pid; do
        if [ ! -z "$pid" ]; then
            echo -e "${YELLOW}   Process $pid durduruluyor...${NC}"
            sudo kill -9 $pid 2>/dev/null || true
        fi
    done
    sleep 2
fi

# fuser ile zorla temizle
echo -e "${YELLOW}🧹 Port ${APP_PORT} zorla temizleniyor...${NC}"
sudo fuser -k ${APP_PORT}/tcp 2>/dev/null || true
sleep 3

# Node process'lerini kontrol et
echo -e "${YELLOW}🔍 Node process'leri kontrol ediliyor...${NC}"
ps aux | grep -E "node.*3040|next.*3040" | grep -v grep | awk '{print $2}' | while read pid; do
    if [ ! -z "$pid" ]; then
        echo -e "${YELLOW}   Node process $pid durduruluyor...${NC}"
        sudo kill -9 $pid 2>/dev/null || true
    fi
done
sleep 2

# 3. Port'un boş olduğunu doğrula
echo -e "${YELLOW}🔍 Port ${APP_PORT} kontrol ediliyor...${NC}"
sleep 2

if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${RED}❌ Port ${APP_PORT} hala kullanımda!${NC}"
    echo -e "${YELLOW}📋 Kullanan process'ler:${NC}"
    sudo lsof -i:${APP_PORT}
    echo ""
    echo -e "${YELLOW}💡 Manuel olarak durdurun:${NC}"
    sudo lsof -ti:${APP_PORT} | xargs -r sudo kill -9
    sleep 2
fi

# Tekrar kontrol
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${RED}❌ Port ${APP_PORT} hala kullanımda!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Port ${APP_PORT} boş${NC}"

# 4. .env dosyasını kontrol et
echo -e "${YELLOW}📝 .env dosyası kontrol ediliyor...${NC}"
cd "$APP_DIR"

if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 .env dosyası oluşturuluyor...${NC}"
    cat > .env << EOF
NODE_ENV=production
PORT=${APP_PORT}
EOF
else
    if grep -q "PORT=" .env; then
        sed -i "s/PORT=.*/PORT=${APP_PORT}/" .env
    else
        echo "PORT=${APP_PORT}" >> .env
    fi
    echo -e "${GREEN}✅ .env dosyasında PORT=${APP_PORT}${NC}"
fi

# 5. PM2 ile başlat
echo -e "${YELLOW}🚀 ${APP_NAME} port ${APP_PORT}'de başlatılıyor...${NC}"
pm2 start npm --name "${APP_NAME}" -- start
sleep 5

# 6. PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 7. Port kontrolü
echo -e "${YELLOW}🔍 Port ${APP_PORT} kontrol ediliyor...${NC}"
sleep 3

if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port ${APP_PORT} dinleniyor${NC}"
    sudo lsof -i:${APP_PORT} | head -2
else
    echo -e "${RED}❌ Port ${APP_PORT} hala dinlenmiyor!${NC}"
    echo -e "${YELLOW}💡 Logları kontrol edin:${NC}"
    pm2 logs "${APP_NAME}" --lines 10
    exit 1
fi

# 8. PM2'ye kaydet
pm2 save

# 9. Test
echo -e "${YELLOW}🧪 Test ediliyor...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT} || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Uygulama çalışıyor! (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  HTTP kodu: $HTTP_CODE${NC}"
fi

echo ""
echo -e "${GREEN}✅ Port ${APP_PORT} sorunu çözüldü!${NC}"
echo ""
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status ${APP_NAME}"
echo "   pm2 logs ${APP_NAME}"
echo "   curl -I http://localhost:${APP_PORT}"

