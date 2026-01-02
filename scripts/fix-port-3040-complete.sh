#!/bin/bash

# Port 3040 sorununu tamamen çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_PORT=3040
APP_NAME="foto-ugur-app"
APP_DIR="$HOME/premiumfoto"

echo -e "${YELLOW}🔧 Port ${APP_PORT} sorunu çözülüyor...${NC}"

# 1. PM2'de foto-ugur-app'i durdur
echo -e "${YELLOW}🛑 ${APP_NAME} durduruluyor...${NC}"
if pm2 list | grep -q "${APP_NAME}"; then
    pm2 stop "${APP_NAME}" || true
    pm2 delete "${APP_NAME}" || true
    sleep 2
    echo -e "${GREEN}✅ ${APP_NAME} durduruldu${NC}"
fi

# 2. Port 3040'ı kullanan tüm process'leri bul ve durdur
echo -e "${YELLOW}🧹 Port ${APP_PORT} temizleniyor...${NC}"

# Tüm process'leri listele ve durdur
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} kullanımda, process'ler durduruluyor...${NC}"
    sudo lsof -i:${APP_PORT} | tail -n +2 | awk '{print $2}' | sort -u | while read pid; do
        if [ ! -z "$pid" ] && [ "$pid" != "PID" ]; then
            echo -e "${YELLOW}   Process $pid durduruluyor...${NC}"
            sudo kill -9 $pid 2>/dev/null || true
        fi
    done
    sleep 2
fi

# fuser ile zorla temizle
sudo fuser -k ${APP_PORT}/tcp 2>/dev/null || true
sleep 2

# Node process'lerini kontrol et
pkill -9 -f "next start -p ${APP_PORT}" 2>/dev/null || true
pkill -9 -f "node.*${APP_PORT}" 2>/dev/null || true
sleep 2

# Port'un boş olduğunu doğrula
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${RED}❌ Port ${APP_PORT} hala kullanımda!${NC}"
    sudo lsof -i:${APP_PORT}
    exit 1
fi

echo -e "${GREEN}✅ Port ${APP_PORT} temizlendi${NC}"

# 3. .env dosyasını kontrol et
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
        echo -e "${GREEN}✅ .env dosyasında PORT=${APP_PORT} olarak güncellendi${NC}"
    else
        echo "PORT=${APP_PORT}" >> .env
        echo -e "${GREEN}✅ .env dosyasına PORT=${APP_PORT} eklendi${NC}"
    fi
fi

# 4. package.json'da start script'ini kontrol et
if [ -f "package.json" ]; then
    if grep -q '"start":' package.json; then
        if ! grep -q '"start":.*-p 3040' package.json; then
            echo -e "${YELLOW}⚠️  package.json start script'i port 3040 kullanmıyor, güncelleniyor...${NC}"
            sed -i 's/"start": "next start -p [0-9]*/"start": "next start -p 3040/' package.json
            echo -e "${GREEN}✅ package.json start script'i güncellendi${NC}"
        fi
    fi
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
    echo "   pm2 logs ${APP_NAME} --lines 30"
    pm2 logs "${APP_NAME}" --lines 10
    exit 1
fi

# 8. PM2'ye kaydet
pm2 save

# 9. Test
echo -e "${YELLOW}🧪 Test ediliyor...${NC}"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT} | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ Uygulama çalışıyor!${NC}"
else
    echo -e "${YELLOW}⚠️  Uygulama yanıt vermiyor, logları kontrol edin${NC}"
fi

echo ""
echo -e "${GREEN}✅ Port ${APP_PORT} sorunu çözüldü!${NC}"
echo ""
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status ${APP_NAME}"
echo "   pm2 logs ${APP_NAME}"
echo "   curl -I http://localhost:${APP_PORT}"

