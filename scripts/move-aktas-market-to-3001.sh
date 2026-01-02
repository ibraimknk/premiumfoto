#!/bin/bash

# fikirtepetekelpaket-app'i durdur ve aktas-market'i port 3001'de başlat

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PM2_APP_NAME_FIKIRTEPE="fikirtepetekelpaket-app"
PM2_APP_NAME_AKTAS="aktas-market"
APP_PORT=3001

echo -e "${YELLOW}🔧 fikirtepetekelpaket-app durduruluyor ve aktas-market port ${APP_PORT}'de başlatılıyor...${NC}"

# 1. fikirtepetekelpaket-app'i durdur
if pm2 list | grep -q "${PM2_APP_NAME_FIKIRTEPE}"; then
    echo -e "${YELLOW}🛑 ${PM2_APP_NAME_FIKIRTEPE} durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME_FIKIRTEPE}" || true
    pm2 delete "${PM2_APP_NAME_FIKIRTEPE}" || true
    echo -e "${GREEN}✅ ${PM2_APP_NAME_FIKIRTEPE} durduruldu ve silindi${NC}"
else
    echo -e "${YELLOW}⚠️  ${PM2_APP_NAME_FIKIRTEPE} zaten durdurulmuş${NC}"
fi

# 2. Port 3001'i temizle
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} kullanımda, temizleniyor...${NC}"
    sudo lsof -ti:${APP_PORT} | xargs sudo kill -9 2>/dev/null || true
    sleep 2
fi

# 3. aktas-market'i durdur (eğer çalışıyorsa)
if pm2 list | grep -q "${PM2_APP_NAME_AKTAS}"; then
    echo -e "${YELLOW}🛑 ${PM2_APP_NAME_AKTAS} durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME_AKTAS}" || true
    pm2 delete "${PM2_APP_NAME_AKTAS}" || true
    echo -e "${GREEN}✅ ${PM2_APP_NAME_AKTAS} durduruldu${NC}"
fi

# 4. aktas-market'in dizinini bul
AKTAS_DIR=""
POSSIBLE_DIRS=(
    "/var/www/aktas-market"
    "/home/ibrahim/aktas-market"
    "/var/www/html"
)

for dir in "${POSSIBLE_DIRS[@]}"; do
    if [ -d "$dir" ] && [ -f "$dir/package.json" ]; then
        AKTAS_DIR="$dir"
        break
    fi
done

if [ -z "$AKTAS_DIR" ]; then
    echo -e "${RED}❌ aktas-market dizini bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Olası dizinler:${NC}"
    for dir in "${POSSIBLE_DIRS[@]}"; do
        echo "   - $dir"
    done
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

# 6. PM2 ecosystem config oluştur
echo -e "${YELLOW}📝 PM2 ecosystem config oluşturuluyor...${NC}"
cat > "$AKTAS_DIR/ecosystem-aktas-market.config.js" << PM2EOF
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

# 7. PM2 ile başlat
echo -e "${YELLOW}🚀 ${PM2_APP_NAME_AKTAS} port ${APP_PORT}'de başlatılıyor...${NC}"
pm2 start "$AKTAS_DIR/ecosystem-aktas-market.config.js"
pm2 save

# 8. PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 9. Port kontrolü
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
echo -e "${GREEN}✅ ${PM2_APP_NAME_AKTAS} port ${APP_PORT}'de başlatıldı!${NC}"
echo ""
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status ${PM2_APP_NAME_AKTAS}"
echo "   pm2 logs ${PM2_APP_NAME_AKTAS}"
echo "   pm2 restart ${PM2_APP_NAME_AKTAS}"

