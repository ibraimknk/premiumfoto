#!/bin/bash

# Port 3040 sorununu debug et ve çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="$HOME/premiumfoto"
TARGET_PORT=3040
PM2_APP_NAME="foto-ugur-app"

echo -e "${BLUE}🔍 Port ${TARGET_PORT} debug ediliyor...${NC}"
echo ""

cd "$APP_DIR"

# 1. PM2 loglarını kontrol et
echo -e "${YELLOW}1️⃣ PM2 logları (son 50 satır):${NC}"
pm2 logs "$PM2_APP_NAME" --lines 50 --nostream
echo ""

# 2. PM2 process detaylarını göster
echo -e "${YELLOW}2️⃣ PM2 process detayları:${NC}"
pm2 describe "$PM2_APP_NAME"
echo ""

# 3. Port 3040'ı manuel test et
echo -e "${YELLOW}3️⃣ Port ${TARGET_PORT} manuel test:${NC}"
if curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:${TARGET_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port ${TARGET_PORT} çalışıyor!${NC}"
    curl -I http://localhost:${TARGET_PORT} 2>/dev/null | head -5
else
    echo -e "${RED}❌ Port ${TARGET_PORT} çalışmıyor${NC}"
fi
echo ""

# 4. Tüm process'leri kontrol et
echo -e "${YELLOW}4️⃣ Tüm next-server process'leri:${NC}"
ps aux | grep -E "next|node.*3040" | grep -v grep
echo ""

# 5. Port 3040'ı kullanan process'leri bul
echo -e "${YELLOW}5️⃣ Port ${TARGET_PORT} kullanan process'ler:${NC}"
sudo lsof -i:${TARGET_PORT} 2>/dev/null || echo -e "${RED}   Port ${TARGET_PORT} kullanılmıyor${NC}"
echo ""

# 6. PM2'yi yeniden başlat (daha agresif)
echo -e "${YELLOW}6️⃣ PM2 yeniden başlatılıyor (agresif)...${NC}"
pm2 stop "$PM2_APP_NAME" 2>/dev/null || true
pm2 delete "$PM2_APP_NAME" 2>/dev/null || true
sleep 3

# Port'u temizle
if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}   Port ${TARGET_PORT} temizleniyor...${NC}"
    sudo lsof -ti:${TARGET_PORT} | xargs -r sudo kill -9 2>/dev/null || true
    sleep 2
fi

# Ecosystem dosyasını kontrol et
if [ ! -f "ecosystem.config.js" ]; then
    echo -e "${YELLOW}   Ecosystem dosyası oluşturuluyor...${NC}"
    cat > "$APP_DIR/ecosystem.config.js" << EOF
module.exports = {
  apps: [{
    name: '${PM2_APP_NAME}',
    script: 'node_modules/.bin/next',
    args: 'start -p ${TARGET_PORT}',
    cwd: '${APP_DIR}',
    env: {
      NODE_ENV: 'production',
      PORT: '${TARGET_PORT}'
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
fi

# PM2'yi başlat
echo -e "${YELLOW}   PM2 başlatılıyor...${NC}"
pm2 start ecosystem.config.js
pm2 save

sleep 5

# 7. Port kontrolü (daha uzun bekle)
echo -e "${YELLOW}7️⃣ Port ${TARGET_PORT} kontrol ediliyor (30 saniye)...${NC}"
PORT_OPEN=false
for i in {1..30}; do
    if sudo lsof -i:${TARGET_PORT} > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Port ${TARGET_PORT} açıldı! (${i}. denemede)${NC}"
        sudo lsof -i:${TARGET_PORT} | head -3
        PORT_OPEN=true
        break
    fi
    
    # Her 5 saniyede bir test isteği gönder
    if [ $((i % 5)) -eq 0 ]; then
        echo -e "${YELLOW}   Test isteği gönderiliyor... ($i/30)${NC}"
        curl -s -o /dev/null -w "HTTP: %{http_code}\n" --max-time 2 http://localhost:${TARGET_PORT} 2>/dev/null || true
    else
        echo -e "${YELLOW}   Bekleniyor... ($i/30)${NC}"
    fi
    
    sleep 1
done

if [ "$PORT_OPEN" = false ]; then
    echo -e "${RED}❌ Port ${TARGET_PORT} hala açılmadı!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Son PM2 logları:${NC}"
    pm2 logs "$PM2_APP_NAME" --lines 30 --nostream
    echo ""
    echo -e "${YELLOW}💡 Manuel test:${NC}"
    echo "   cd $APP_DIR"
    echo "   npm start"
    exit 1
fi

# 8. 502 scriptini çalıştır
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

