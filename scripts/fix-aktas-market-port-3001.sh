#!/bin/bash

# aktas-market'i port 3001'e taşı ve fikirtepetekelpaket-app'i durdur

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PM2_APP_NAME_FIKIRTEPE="fikirtepetekelpaket-app"
PM2_APP_NAME_AKTAS="aktas-market"
APP_PORT=3001

echo -e "${YELLOW}🔧 aktas-market port ${APP_PORT}'e taşınıyor...${NC}"

# 1. fikirtepetekelpaket-app'i durdur
if pm2 list | grep -q "${PM2_APP_NAME_FIKIRTEPE}"; then
    echo -e "${YELLOW}🛑 ${PM2_APP_NAME_FIKIRTEPE} durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME_FIKIRTEPE}" || true
    pm2 delete "${PM2_APP_NAME_FIKIRTEPE}" || true
    echo -e "${GREEN}✅ ${PM2_APP_NAME_FIKIRTEPE} durduruldu ve silindi${NC}"
fi

# 2. Port 3001'i temizle
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} kullanımda, temizleniyor...${NC}"
    sudo lsof -ti:${APP_PORT} | xargs sudo kill -9 2>/dev/null || true
    sleep 2
fi

# 3. aktas-market'i durdur
if pm2 list | grep -q "${PM2_APP_NAME_AKTAS}"; then
    echo -e "${YELLOW}🛑 ${PM2_APP_NAME_AKTAS} durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME_AKTAS}" || true
    pm2 delete "${PM2_APP_NAME_AKTAS}" || true
    echo -e "${GREEN}✅ ${PM2_APP_NAME_AKTAS} durduruldu${NC}"
fi

# 4. aktas-market'in dizinini bul (PM2'den al)
AKTAS_DIR=""
if pm2 describe "${PM2_APP_NAME_AKTAS}" > /dev/null 2>&1; then
    AKTAS_DIR=$(pm2 describe "${PM2_APP_NAME_AKTAS}" | grep "cwd" | awk '{print $4}' || echo "")
fi

# Eğer bulunamadıysa, olası dizinleri kontrol et
if [ -z "$AKTAS_DIR" ] || [ ! -d "$AKTAS_DIR" ]; then
    POSSIBLE_DIRS=(
        "/var/www/aktas-market"
        "/home/ibrahim/aktas-market"
        "/var/www/fikirtepetekelpaket.com"
    )
    
    for dir in "${POSSIBLE_DIRS[@]}"; do
        if [ -d "$dir" ] && [ -f "$dir/package.json" ]; then
            AKTAS_DIR="$dir"
            break
        fi
    done
fi

if [ -z "$AKTAS_DIR" ] || [ ! -d "$AKTAS_DIR" ]; then
    echo -e "${RED}❌ aktas-market dizini bulunamadı!${NC}"
    echo -e "${YELLOW}💡 PM2'den dizin bilgisini kontrol edin:${NC}"
    echo "   pm2 describe ${PM2_APP_NAME_AKTAS}"
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

# 6. package.json'da start script'ini kontrol et (eğer varsa)
if [ -f "package.json" ]; then
    if grep -q '"start":' package.json; then
        # Start script'inde port varsa güncelle
        if grep -q '"start":.*-p' package.json; then
            sed -i "s/\"start\":[^,]*\"next start -p [0-9]*/\"start\": \"next start -p ${APP_PORT}/" package.json
            echo -e "${GREEN}✅ package.json start script'i güncellendi${NC}"
        fi
    fi
fi

# 7. PM2 ecosystem config oluştur (.cjs uzantısı kullan - ES module için)
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

# 8. PM2 ile başlat
echo -e "${YELLOW}🚀 ${PM2_APP_NAME_AKTAS} port ${APP_PORT}'de başlatılıyor...${NC}"
pm2 start "$AKTAS_DIR/ecosystem-aktas-market.config.cjs"
pm2 save

# 9. PM2 durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 10. Port kontrolü
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

