#!/bin/bash

# fikirtepetekelpaket.com uygulamasını port 3001'de başlat

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_NAME="fikirtepetekelpaket"
APP_PORT=3001
PM2_APP_NAME="fikirtepetekelpaket-app"
APP_DIR="/home/ibrahim/${APP_NAME}"

echo -e "${YELLOW}🚀 ${APP_NAME} uygulaması port ${APP_PORT}'de başlatılıyor...${NC}"

# 1. Uygulama dizini kontrolü
if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}❌ Uygulama dizini bulunamadı: $APP_DIR${NC}"
    echo -e "${YELLOW}💡 Önce uygulamayı klonlayın veya dizini oluşturun${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Uygulama dizini mevcut: $APP_DIR${NC}"

# 2. Port 3001 kullanımda mı kontrol et
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} kullanımda, durduruluyor...${NC}"
    sudo lsof -ti:${APP_PORT} | xargs sudo kill -9 2>/dev/null || true
    sleep 2
fi

# 3. PM2'de zaten çalışıyor mu kontrol et
if pm2 list | grep -q "${PM2_APP_NAME}"; then
    echo -e "${YELLOW}🔄 PM2 uygulaması yeniden başlatılıyor...${NC}"
    pm2 restart "${PM2_APP_NAME}" --update-env
else
    echo -e "${YELLOW}🚀 PM2 uygulaması başlatılıyor...${NC}"
    
    cd "$APP_DIR"
    
    # package.json kontrolü
    if [ ! -f "package.json" ]; then
        echo -e "${RED}❌ package.json bulunamadı!${NC}"
        exit 1
    fi
    
    # .env dosyası kontrolü ve PORT ayarı
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
        else
            echo "PORT=${APP_PORT}" >> .env
        fi
    fi
    
    # PM2 ecosystem dosyası oluştur
    cat > "$APP_DIR/ecosystem.config.js" << PM2EOF
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
    
    # PM2 ile başlat
    pm2 start "$APP_DIR/ecosystem.config.js"
    pm2 save
fi

# 4. PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 5. Port kontrolü
echo -e "${YELLOW}🔍 Port ${APP_PORT} kontrol ediliyor...${NC}"
sleep 2
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port ${APP_PORT} dinleniyor${NC}"
    sudo lsof -i:${APP_PORT} | head -2
else
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} henüz dinlenmiyor, logları kontrol edin${NC}"
fi

echo ""
echo -e "${GREEN}✅ ${APP_NAME} uygulaması port ${APP_PORT}'de başlatıldı!${NC}"
echo ""
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status ${PM2_APP_NAME}"
echo "   pm2 logs ${PM2_APP_NAME}"
echo "   pm2 restart ${PM2_APP_NAME}"
echo "   pm2 stop ${PM2_APP_NAME}"

