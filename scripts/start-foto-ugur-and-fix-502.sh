#!/bin/bash

# foto-ugur-app'i başlat ve 502 hatasını çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="$HOME/premiumfoto"
TARGET_PORT=3040

echo -e "${BLUE}🚀 foto-ugur-app başlatılıyor ve 502 hatası çözülüyor...${NC}"
echo ""

# 1. Dizin kontrolü
if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}❌ Dizin bulunamadı: $APP_DIR${NC}"
    exit 1
fi

cd "$APP_DIR"

# 2. Port 3040'ı temizle (eğer kullanılıyorsa)
echo -e "${YELLOW}🔍 Port ${TARGET_PORT} kontrol ediliyor...${NC}"
if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${TARGET_PORT} kullanımda, temizleniyor...${NC}"
    sudo lsof -ti:${TARGET_PORT} | xargs -r sudo kill -9 2>/dev/null || true
    sleep 2
fi

# 3. .env kontrolü
echo -e "${YELLOW}🔍 .env dosyası kontrol ediliyor...${NC}"
if [ -f ".env" ]; then
    if ! grep -q "PORT=${TARGET_PORT}" .env; then
        echo -e "${YELLOW}📝 .env dosyasına PORT=${TARGET_PORT} ekleniyor...${NC}"
        if grep -q "^PORT=" .env; then
            sed -i "s/^PORT=.*/PORT=${TARGET_PORT}/" .env
        else
            echo "PORT=${TARGET_PORT}" >> .env
        fi
    fi
    echo -e "${GREEN}✅ .env dosyası hazır${NC}"
else
    echo -e "${YELLOW}⚠️  .env dosyası bulunamadı, oluşturuluyor...${NC}"
    echo "PORT=${TARGET_PORT}" > .env
fi

# 4. PM2 durumu kontrol et
echo -e "${YELLOW}🔍 PM2 durumu kontrol ediliyor...${NC}"
if pm2 list | grep -q "foto-ugur-app"; then
    echo -e "${YELLOW}🔄 foto-ugur-app yeniden başlatılıyor...${NC}"
    pm2 restart foto-ugur-app --update-env
    sleep 3
else
    echo -e "${YELLOW}🚀 foto-ugur-app başlatılıyor...${NC}"
    
    # PM2 ecosystem dosyası var mı kontrol et
    if [ -f "ecosystem.config.js" ] || [ -f "ecosystem.config.cjs" ]; then
        ECOSYSTEM_FILE=$(ls ecosystem.config.* 2>/dev/null | head -1)
        pm2 start "$ECOSYSTEM_FILE" --update-env
    else
        # Manuel başlat
        pm2 start npm --name "foto-ugur-app" -- start --update-env
    fi
    sleep 3
fi

# 5. Port kontrolü
echo -e "${YELLOW}🔍 Port ${TARGET_PORT} dinleniyor mu kontrol ediliyor...${NC}"
for i in {1..10}; do
    if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port ${TARGET_PORT} dinleniyor!${NC}"
        break
    else
        if [ $i -eq 10 ]; then
            echo -e "${RED}❌ Port ${TARGET_PORT} hala dinlenmiyor!${NC}"
            echo -e "${YELLOW}📋 PM2 logları:${NC}"
            pm2 logs foto-ugur-app --lines 20 --nostream
            exit 1
        fi
        echo -e "${YELLOW}⏳ Bekleniyor... ($i/10)${NC}"
        sleep 2
    fi
done

# 6. 502 scriptini çalıştır
echo ""
echo -e "${BLUE}🔧 502 hatası çözülüyor...${NC}"
if [ -f "scripts/fix-502-dugunkarem-final.sh" ]; then
    sudo bash scripts/fix-502-dugunkarem-final.sh
else
    echo -e "${RED}❌ fix-502-dugunkarem-final.sh bulunamadı!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"
echo -e "${YELLOW}📋 Kontrol komutları:${NC}"
echo "   pm2 status"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

