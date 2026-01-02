#!/bin/bash

# Port 3040 sorununu çöz - rebuild ve restart

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="$HOME/premiumfoto"
TARGET_PORT=3040

echo -e "${BLUE}🔧 Port ${TARGET_PORT} sorunu çözülüyor (rebuild)...${NC}"
echo ""

cd "$APP_DIR"

# 1. PM2'yi durdur
echo -e "${YELLOW}1️⃣ PM2 uygulamaları durduruluyor...${NC}"
pm2 stop foto-ugur-app 2>/dev/null || true
pm2 delete foto-ugur-app 2>/dev/null || true
sleep 2

# 2. Port 3040'ı temizle
echo -e "${YELLOW}2️⃣ Port ${TARGET_PORT} temizleniyor...${NC}"
if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
    sudo lsof -ti:${TARGET_PORT} | xargs -r sudo kill -9 2>/dev/null || true
    sleep 2
fi

# 3. .next klasörünü temizle
echo -e "${YELLOW}3️⃣ .next klasörü temizleniyor...${NC}"
rm -rf .next
echo -e "${GREEN}✅ .next klasörü temizlendi${NC}"

# 4. node_modules/.cache temizle
echo -e "${YELLOW}4️⃣ node_modules/.cache temizleniyor...${NC}"
rm -rf node_modules/.cache 2>/dev/null || true
echo -e "${GREEN}✅ Cache temizlendi${NC}"

# 5. .env kontrolü
echo -e "${YELLOW}5️⃣ .env dosyası kontrol ediliyor...${NC}"
if [ -f ".env" ]; then
    if ! grep -q "PORT=${TARGET_PORT}" .env; then
        if grep -q "^PORT=" .env; then
            sed -i "s/^PORT=.*/PORT=${TARGET_PORT}/" .env
        else
            echo "PORT=${TARGET_PORT}" >> .env
        fi
        echo -e "${GREEN}✅ PORT=${TARGET_PORT} .env'e eklendi${NC}"
    else
        echo -e "${GREEN}✅ .env dosyası hazır${NC}"
    fi
else
    echo "PORT=${TARGET_PORT}" > .env
    echo -e "${GREEN}✅ .env dosyası oluşturuldu${NC}"
fi

# 6. Prisma client'ı yeniden oluştur
echo -e "${YELLOW}6️⃣ Prisma client yeniden oluşturuluyor...${NC}"
npx prisma generate
echo -e "${GREEN}✅ Prisma client hazır${NC}"

# 7. Build yap
echo -e "${YELLOW}7️⃣ Production build oluşturuluyor...${NC}"
npm run build
echo -e "${GREEN}✅ Build tamamlandı${NC}"

# 8. PM2'yi başlat
echo -e "${YELLOW}8️⃣ PM2 uygulaması başlatılıyor...${NC}"

# PM2 ecosystem dosyası var mı kontrol et
if [ -f "ecosystem.config.js" ] || [ -f "ecosystem.config.cjs" ]; then
    ECOSYSTEM_FILE=$(ls ecosystem.config.* 2>/dev/null | head -1)
    pm2 start "$ECOSYSTEM_FILE" --update-env
else
    # Manuel başlat
    pm2 start npm --name "foto-ugur-app" -- start --update-env
fi

sleep 5

# 9. Port kontrolü
echo -e "${YELLOW}9️⃣ Port ${TARGET_PORT} kontrol ediliyor...${NC}"
for i in {1..15}; do
    if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port ${TARGET_PORT} dinleniyor!${NC}"
        
        # PM2 durumu
        echo ""
        echo -e "${YELLOW}📋 PM2 durumu:${NC}"
        pm2 status
        
        # Port detayları
        echo ""
        echo -e "${YELLOW}📋 Port ${TARGET_PORT} detayları:${NC}"
        sudo lsof -i:${TARGET_PORT}
        
        break
    else
        if [ $i -eq 15 ]; then
            echo -e "${RED}❌ Port ${TARGET_PORT} hala dinlenmiyor!${NC}"
            echo -e "${YELLOW}📋 PM2 logları:${NC}"
            pm2 logs foto-ugur-app --lines 30 --nostream
            exit 1
        fi
        echo -e "${YELLOW}⏳ Bekleniyor... ($i/15)${NC}"
        sleep 2
    fi
done

# 10. 502 scriptini çalıştır
echo ""
echo -e "${BLUE}🔧 502 hatası çözülüyor...${NC}"
if [ -f "scripts/fix-502-dugunkarem-final.sh" ]; then
    sudo bash scripts/fix-502-dugunkarem-final.sh
else
    echo -e "${YELLOW}⚠️  fix-502-dugunkarem-final.sh bulunamadı, manuel kontrol gerekebilir${NC}"
fi

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I http://localhost:${TARGET_PORT}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

