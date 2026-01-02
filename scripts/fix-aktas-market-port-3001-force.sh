#!/bin/bash

# aktas-market'i port 3001'e taşı - port çakışmasını zorla çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PM2_APP_NAME_FIKIRTEPE="fikirtepetekelpaket-app"
PM2_APP_NAME_AKTAS="aktas-market"
APP_PORT=3001
AKTAS_DIR="/var/www/fikirtepetekelpaket.com"

echo -e "${YELLOW}🔧 aktas-market port ${APP_PORT}'e taşınıyor (zorla)...${NC}"

# 0. Eski config dosyalarını temizle
echo -e "${YELLOW}🧹 Eski config dosyaları temizleniyor...${NC}"
rm -f "$AKTAS_DIR/ecosystem-aktas-market.config.js"
rm -f "$AKTAS_DIR/ecosystem-aktas-market.config.cjs"
echo -e "${GREEN}✅ Eski config dosyaları temizlendi${NC}"

# 1. fikirtepetekelpaket-app'i durdur
if pm2 list | grep -q "${PM2_APP_NAME_FIKIRTEPE}"; then
    echo -e "${YELLOW}🛑 ${PM2_APP_NAME_FIKIRTEPE} durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME_FIKIRTEPE}" || true
    pm2 delete "${PM2_APP_NAME_FIKIRTEPE}" || true
    echo -e "${GREEN}✅ ${PM2_APP_NAME_FIKIRTEPE} durduruldu ve silindi${NC}"
fi

# 2. Port 3001'i kullanan tüm process'leri bul ve durdur
echo -e "${YELLOW}🔍 Port ${APP_PORT} kullanan process'ler kontrol ediliyor...${NC}"
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} kullanımda, process'ler durduruluyor...${NC}"
    # Tüm process'leri listele
    sudo lsof -i:${APP_PORT} | tail -n +2 | awk '{print $2}' | sort -u | while read pid; do
        if [ ! -z "$pid" ] && [ "$pid" != "PID" ]; then
            echo -e "${YELLOW}   Process $pid durduruluyor...${NC}"
            sudo kill -9 $pid 2>/dev/null || true
        fi
    done
    sleep 2
    
    # Tekrar kontrol et
    if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
        echo -e "${RED}⚠️  Port ${APP_PORT} hala kullanımda, zorla temizleniyor...${NC}"
        sudo fuser -k ${APP_PORT}/tcp 2>/dev/null || true
        sleep 2
    fi
    echo -e "${GREEN}✅ Port ${APP_PORT} temizlendi${NC}"
fi

# 3. aktas-market'i durdur
if pm2 list | grep -q "${PM2_APP_NAME_AKTAS}"; then
    echo -e "${YELLOW}🛑 ${PM2_APP_NAME_AKTAS} durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME_AKTAS}" || true
    pm2 delete "${PM2_APP_NAME_AKTAS}" || true
    sleep 2
    echo -e "${GREEN}✅ ${PM2_APP_NAME_AKTAS} durduruldu${NC}"
fi

# 4. Dizin kontrolü
if [ ! -d "$AKTAS_DIR" ]; then
    echo -e "${RED}❌ aktas-market dizini bulunamadı: $AKTAS_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✅ aktas-market dizini bulundu: $AKTAS_DIR${NC}"

# 5. .env dosyasını güncelle veya oluştur
cd "$AKTAS_DIR"
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 .env dosyası oluşturuluyor...${NC}"
    cat > .env << EOF
NODE_ENV=production
PORT=${APP_PORT}
EOF
else
    # PORT'u güncelle
    if grep -q "PORT=" .env; then
        sed -i "s/PORT=.*/PORT=${APP_PORT}/" .env
        echo -e "${GREEN}✅ .env dosyasında PORT=${APP_PORT} olarak güncellendi${NC}"
    else
        echo "PORT=${APP_PORT}" >> .env
        echo -e "${GREEN}✅ .env dosyasına PORT=${APP_PORT} eklendi${NC}"
    fi
fi

# 6. server.js veya package.json'da port kontrolü
if [ -f "server.js" ]; then
    echo -e "${YELLOW}📝 server.js dosyası kontrol ediliyor...${NC}"
    # server.js'de port kontrolü yap (eğer hardcoded ise)
    if grep -q "listen(3000" server.js; then
        sed -i "s/listen(3000/listen(${APP_PORT}/" server.js
        echo -e "${GREEN}✅ server.js'de port ${APP_PORT} olarak güncellendi${NC}"
    fi
fi

# 7. PM2 ecosystem config oluştur (.cjs uzantısı - ES module uyumluluğu için)
echo -e "${YELLOW}📝 PM2 ecosystem config oluşturuluyor...${NC}"
cat > "$AKTAS_DIR/ecosystem-aktas-market.config.cjs" << PM2EOF
module.exports = {
  apps: [{
    name: '${PM2_APP_NAME_AKTAS}',
    script: 'npm',
    args: 'start',
    cwd: '${AKTAS_DIR}',
    env: {
      NODE_ENV: 'production',
      PORT: ${APP_PORT}
    },
    error_file: '$HOME/.pm2/logs/${PM2_APP_NAME_AKTAS}-error.log',
    out_file: '$HOME/.pm2/logs/${PM2_APP_NAME_AKTAS}-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    instances: 1,
    exec_mode: 'fork'
  }]
}
PM2EOF

echo -e "${GREEN}✅ Config dosyası oluşturuldu: ecosystem-aktas-market.config.cjs${NC}"

# 8. Port'un gerçekten boş olduğunu doğrula
echo -e "${YELLOW}🔍 Port ${APP_PORT} son kontrol...${NC}"
sleep 2
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${RED}❌ Port ${APP_PORT} hala kullanımda!${NC}"
    echo -e "${YELLOW}📋 Kullanan process'ler:${NC}"
    sudo lsof -i:${APP_PORT}
    exit 1
fi
echo -e "${GREEN}✅ Port ${APP_PORT} boş${NC}"

# 9. PM2 ile başlat
echo -e "${YELLOW}🚀 ${PM2_APP_NAME_AKTAS} port ${APP_PORT}'de başlatılıyor...${NC}"
pm2 start "$AKTAS_DIR/ecosystem-aktas-market.config.cjs"
pm2 save

# 10. PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
sleep 3
pm2 status

# 11. Port kontrolü
echo -e "${YELLOW}🔍 Port ${APP_PORT} kontrol ediliyor...${NC}"
sleep 3
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port ${APP_PORT} dinleniyor${NC}"
    sudo lsof -i:${APP_PORT} | head -2
else
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} henüz dinlenmiyor, logları kontrol edin${NC}"
    echo -e "${YELLOW}💡 Loglar: pm2 logs ${PM2_APP_NAME_AKTAS}${NC}"
fi

echo ""
echo -e "${GREEN}✅ ${PM2_APP_NAME_AKTAS} port ${APP_PORT}'de başlatıldı ve PM2'ye kaydedildi!${NC}"
echo ""
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status ${PM2_APP_NAME_AKTAS}"
echo "   pm2 logs ${PM2_APP_NAME_AKTAS}"
echo "   pm2 restart ${PM2_APP_NAME_AKTAS}"

