#!/bin/bash

# PM2 Next.js doğrudan başlatma (npm start yerine next start)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="$HOME/premiumfoto"
TARGET_PORT=3040
PM2_APP_NAME="foto-ugur-app"

echo -e "${BLUE}🔧 PM2 Next.js doğrudan başlatılıyor...${NC}"
echo ""

cd "$APP_DIR"

# 1. PM2'yi durdur
echo -e "${YELLOW}1️⃣ PM2 uygulaması durduruluyor...${NC}"
pm2 stop "$PM2_APP_NAME" 2>/dev/null || true
pm2 delete "$PM2_APP_NAME" 2>/dev/null || true
sleep 2

# 2. Port 3040'ı temizle
echo -e "${YELLOW}2️⃣ Port ${TARGET_PORT} temizleniyor...${NC}"
if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
    sudo lsof -ti:${TARGET_PORT} | xargs -r sudo kill -9 2>/dev/null || true
    sleep 2
fi

# 3. PM2 ecosystem dosyası oluştur (doğrudan next start)
echo -e "${YELLOW}3️⃣ PM2 ecosystem dosyası oluşturuluyor...${NC}"
cat > "$APP_DIR/ecosystem.config.js" << EOF
module.exports = {
  apps: [{
    name: '${PM2_APP_NAME}',
    script: 'node_modules/.bin/next',
    args: 'start -p ${TARGET_PORT}',
    cwd: '${APP_DIR}',
    env: {
      NODE_ENV: 'production',
      PORT: '${TARGET_PORT}',
      PATH: process.env.PATH
    },
    error_file: '$HOME/.pm2/logs/${PM2_APP_NAME}-error.log',
    out_file: '$HOME/.pm2/logs/${PM2_APP_NAME}-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    instances: 1,
    exec_mode: 'fork'
  }]
}
EOF

echo -e "${GREEN}✅ ecosystem.config.js oluşturuldu${NC}"

# 4. .env kontrolü
echo -e "${YELLOW}4️⃣ .env dosyası kontrol ediliyor...${NC}"
if [ -f ".env" ]; then
    if ! grep -q "PORT=${TARGET_PORT}" .env; then
        if grep -q "^PORT=" .env; then
            sed -i "s/^PORT=.*/PORT=${TARGET_PORT}/" .env
        else
            echo "PORT=${TARGET_PORT}" >> .env
        fi
    fi
fi

# 5. PM2'yi başlat
echo -e "${YELLOW}5️⃣ PM2 uygulaması başlatılıyor...${NC}"
pm2 start "$APP_DIR/ecosystem.config.js"
pm2 save

sleep 5

# 6. Port kontrolü
echo -e "${YELLOW}6️⃣ Port ${TARGET_PORT} kontrol ediliyor...${NC}"
for i in {1..20}; do
    if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port ${TARGET_PORT} dinleniyor!${NC}"
        
        # Port detayları
        echo ""
        echo -e "${YELLOW}📋 Port ${TARGET_PORT} detayları:${NC}"
        sudo lsof -i:${TARGET_PORT} | head -3
        
        # PM2 durumu
        echo ""
        echo -e "${YELLOW}📋 PM2 durumu:${NC}"
        pm2 status
        
        # Test isteği gönder (port'u aktif hale getir)
        echo ""
        echo -e "${YELLOW}7️⃣ Test isteği gönderiliyor...${NC}"
        curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:${TARGET_PORT} || true
        
        break
    else
        if [ $i -eq 20 ]; then
            echo -e "${RED}❌ Port ${TARGET_PORT} hala dinlenmiyor!${NC}"
            echo -e "${YELLOW}📋 PM2 logları:${NC}"
            pm2 logs "$PM2_APP_NAME" --lines 30 --nostream
            exit 1
        fi
        echo -e "${YELLOW}⏳ Bekleniyor... ($i/20)${NC}"
        sleep 2
    fi
done

# 7. 502 scriptini çalıştır
echo ""
echo -e "${BLUE}🔧 502 hatası çözülüyor...${NC}"
if [ -f "scripts/fix-502-dugunkarem-final.sh" ]; then
    sudo bash scripts/fix-502-dugunkarem-final.sh
else
    echo -e "${YELLOW}⚠️  fix-502-dugunkarem-final.sh bulunamadı${NC}"
fi

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I http://localhost:${TARGET_PORT}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

