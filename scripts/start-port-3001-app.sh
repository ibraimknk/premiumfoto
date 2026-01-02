#!/bin/bash

# Port 3001'de çalışması gereken projeyi bul ve başlat

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_PORT=3001
PM2_APP_NAME="aktas-market"

echo -e "${BLUE}🔍 Port ${APP_PORT}'de çalışması gereken proje aranıyor...${NC}"
echo ""

# 1. Olası dizinleri kontrol et
echo -e "${YELLOW}1️⃣ Proje dizini aranıyor...${NC}"
POSSIBLE_DIRS=(
    "/var/www/fikirtepetekelpaket.com"
    "/var/www/aktas-market"
    "/home/ibrahim/aktas-market"
    "/home/ibrahim/fikirtepetekelpaket"
)

APP_DIR=""
for dir in "${POSSIBLE_DIRS[@]}"; do
    if [ -d "$dir" ] && [ -f "$dir/package.json" ]; then
        APP_DIR="$dir"
        echo -e "${GREEN}✅ Proje dizini bulundu: $APP_DIR${NC}"
        break
    fi
done

if [ -z "$APP_DIR" ]; then
    echo -e "${RED}❌ Proje dizini bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Kontrol edilen dizinler:${NC}"
    for dir in "${POSSIBLE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo "   - $dir (dizin var ama package.json yok)"
        else
            echo "   - $dir (dizin yok)"
        fi
    done
    exit 1
fi

echo ""

# 2. Port 3001'i temizle
echo -e "${YELLOW}2️⃣ Port ${APP_PORT} kontrol ediliyor...${NC}"
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port ${APP_PORT} kullanımda, temizleniyor...${NC}"
    sudo lsof -ti:${APP_PORT} | xargs sudo kill -9 2>/dev/null || true
    sleep 2
    echo -e "${GREEN}✅ Port ${APP_PORT} temizlendi${NC}"
else
    echo -e "${GREEN}✅ Port ${APP_PORT} boş${NC}"
fi
echo ""

# 3. PM2'de zaten çalışıyor mu kontrol et
echo -e "${YELLOW}3️⃣ PM2 durumu kontrol ediliyor...${NC}"
if pm2 list | grep -q "${PM2_APP_NAME}"; then
    echo -e "${YELLOW}🔄 PM2 uygulaması zaten var, yeniden başlatılıyor...${NC}"
    pm2 restart "${PM2_APP_NAME}" --update-env
    sleep 3
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
            echo -e "${GREEN}✅ .env dosyasında PORT=${APP_PORT} olarak güncellendi${NC}"
        else
            echo "PORT=${APP_PORT}" >> .env
            echo -e "${GREEN}✅ .env dosyasına PORT=${APP_PORT} eklendi${NC}"
        fi
    fi
    
    # PM2 ecosystem config oluştur (.cjs uzantısı - ES module uyumluluğu için)
    echo -e "${YELLOW}📝 PM2 ecosystem config oluşturuluyor...${NC}"
    cat > "$APP_DIR/ecosystem-aktas-market.config.cjs" << PM2EOF
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
    
    echo -e "${GREEN}✅ Config dosyası oluşturuldu${NC}"
    
    # PM2 ile başlat
    pm2 start "$APP_DIR/ecosystem-aktas-market.config.cjs"
    pm2 save
    sleep 3
fi
echo ""

# 4. PM2 durum kontrolü
echo -e "${YELLOW}4️⃣ PM2 durumu kontrol ediliyor...${NC}"
pm2 status
echo ""

# 5. Port kontrolü
echo -e "${YELLOW}5️⃣ Port ${APP_PORT} kontrol ediliyor...${NC}"
sleep 2
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port ${APP_PORT} dinleniyor${NC}"
    sudo lsof -i:${APP_PORT} | head -2
else
    echo -e "${RED}❌ Port ${APP_PORT} henüz dinlenmiyor!${NC}"
    echo -e "${YELLOW}💡 Logları kontrol edin:${NC}"
    echo "   pm2 logs ${PM2_APP_NAME}"
    echo ""
    echo -e "${YELLOW}📋 Son 20 satır log:${NC}"
    pm2 logs ${PM2_APP_NAME} --lines 20 --nostream || true
fi
echo ""

# 6. Test
echo -e "${YELLOW}6️⃣ Uygulama test ediliyor...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:${APP_PORT} 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Uygulama çalışıyor: HTTP ${HTTP_CODE}${NC}"
else
    echo -e "${YELLOW}⚠️  Uygulama henüz yanıt vermiyor: HTTP ${HTTP_CODE}${NC}"
    echo -e "${YELLOW}💡 Biraz bekleyip tekrar deneyin:${NC}"
    echo "   curl http://localhost:${APP_PORT}"
fi

echo ""
echo -e "${GREEN}✅ İşlem tamamlandı!${NC}"
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status ${PM2_APP_NAME}"
echo "   pm2 logs ${PM2_APP_NAME}"
echo "   pm2 restart ${PM2_APP_NAME}"
echo "   pm2 stop ${PM2_APP_NAME}"

