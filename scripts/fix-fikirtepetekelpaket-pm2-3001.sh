#!/bin/bash

# fikirtepetekelpaket-app PM2 uygulamasını port 3001'e güncelle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PM2_APP_NAME="fikirtepetekelpaket-app"
APP_PORT=3001
APP_DIR="/home/ibrahim/premiumfoto"

echo -e "${YELLOW}🔧 ${PM2_APP_NAME} port ${APP_PORT}'e güncelleniyor...${NC}"

# 1. PM2 uygulamasını durdur
if pm2 list | grep -q "${PM2_APP_NAME}"; then
    echo -e "${YELLOW}🛑 PM2 uygulaması durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME}" || true
    pm2 delete "${PM2_APP_NAME}" || true
    echo -e "${GREEN}✅ PM2 uygulaması silindi${NC}"
fi

# 2. Port 3001'i temizle
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} kullanımda, temizleniyor...${NC}"
    sudo lsof -ti:${APP_PORT} | xargs sudo kill -9 2>/dev/null || true
    sleep 2
fi

# 3. .env dosyasını güncelle
cd "$APP_DIR"
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

# 4. package.json'ı DEĞİŞTİRME - sadece PM2 ecosystem config'inde PORT kullan
# package.json'ı değiştirmiyoruz çünkü bu premiumfoto için, port 3040'da kalmalı
echo -e "${YELLOW}ℹ️  package.json değiştirilmiyor (premiumfoto port 3040'da kalmalı)${NC}"

# 5. PM2 ecosystem config oluştur
echo -e "${YELLOW}📝 PM2 ecosystem config oluşturuluyor...${NC}"
cat > "$APP_DIR/ecosystem-fikirtepetekelpaket.config.js" << PM2EOF
module.exports = {
  apps: [{
    name: '${PM2_APP_NAME}',
    script: 'npm',
    args: 'start',
    cwd: '${APP_DIR}',
    env: {
      NODE_ENV: 'production',
      PORT: ${APP_PORT}
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
PM2EOF

# 6. PM2 ile başlat
echo -e "${YELLOW}🚀 PM2 uygulaması başlatılıyor...${NC}"
pm2 start "$APP_DIR/ecosystem-fikirtepetekelpaket.config.js"
pm2 save

# 7. PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 8. Port kontrolü
echo -e "${YELLOW}🔍 Port ${APP_PORT} kontrol ediliyor...${NC}"
sleep 3
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port ${APP_PORT} dinleniyor${NC}"
    sudo lsof -i:${APP_PORT} | head -2
else
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} henüz dinlenmiyor, logları kontrol edin${NC}"
    echo -e "${YELLOW}💡 Loglar: pm2 logs ${PM2_APP_NAME}${NC}"
fi

echo ""
echo -e "${GREEN}✅ ${PM2_APP_NAME} port ${APP_PORT}'de başlatıldı!${NC}"
echo ""
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status ${PM2_APP_NAME}"
echo "   pm2 logs ${PM2_APP_NAME}"
echo "   pm2 restart ${PM2_APP_NAME}"

