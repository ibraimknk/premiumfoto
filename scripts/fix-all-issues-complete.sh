#!/bin/bash

# Tüm sorunları düzelt: Port çakışmaları, server.js syntax hatası, PM2 restart döngüleri

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Tüm sorunlar düzeltiliyor...${NC}"

# 1. PM2'yi durdur
echo -e "${YELLOW}🛑 PM2 uygulamaları durduruluyor...${NC}"
pm2 stop all || true
pm2 delete all || true
sleep 2

# 2. Portları temizle
echo -e "${YELLOW}🧹 Portlar temizleniyor...${NC}"
sudo fuser -k 3040/tcp 2>/dev/null || true
sudo fuser -k 3001/tcp 2>/dev/null || true
sudo lsof -ti:3040 | xargs sudo kill -9 2>/dev/null || true
sudo lsof -ti:3001 | xargs sudo kill -9 2>/dev/null || true
sleep 3

# 3. server.js dosyasını düzelt
echo -e "${YELLOW}🔧 server.js dosyası düzeltiliyor...${NC}"
AKTAS_DIR="/var/www/fikirtepetekelpaket.com"
if [ -f "$AKTAS_DIR/server.js" ]; then
    # Yedek al
    cp "$AKTAS_DIR/server.js" "$AKTAS_DIR/server.js.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Syntax hatasını düzelt: process.env.PORT || 3001|| 3001import -> process.env.PORT || 3001
    sed -i 's/process\.env\.PORT || 3001|| 3001/process.env.PORT || 3001/' "$AKTAS_DIR/server.js"
    
    # Eğer hala sorun varsa, listen satırını düzelt
    if grep -q "process.env.PORT || 3001||" "$AKTAS_DIR/server.js"; then
        sed -i 's/process\.env\.PORT || 3001||[^ ]*/process.env.PORT || 3001/' "$AKTAS_DIR/server.js"
    fi
    
    # listen() satırını kontrol et ve düzelt
    if grep -q "listen(process.env.PORT || 3001||" "$AKTAS_DIR/server.js"; then
        sed -i 's/listen(process\.env\.PORT || 3001||[^)]*/listen(process.env.PORT || 3001/' "$AKTAS_DIR/server.js"
    fi
    
    echo -e "${GREEN}✅ server.js düzeltildi${NC}"
    
    # Kontrol et
    if node -c "$AKTAS_DIR/server.js" 2>/dev/null; then
        echo -e "${GREEN}✅ server.js syntax kontrolü başarılı${NC}"
    else
        echo -e "${YELLOW}⚠️  server.js syntax kontrolü başarısız, manuel kontrol gerekebilir${NC}"
        echo -e "${YELLOW}💡 İlk satırları kontrol edin:${NC}"
        head -5 "$AKTAS_DIR/server.js"
    fi
else
    echo -e "${RED}❌ server.js bulunamadı: $AKTAS_DIR/server.js${NC}"
fi

# 4. .env dosyalarını kontrol et
echo -e "${YELLOW}📝 .env dosyaları kontrol ediliyor...${NC}"

# premiumfoto .env
if [ -f "$HOME/premiumfoto/.env" ]; then
    if ! grep -q "PORT=3040" "$HOME/premiumfoto/.env"; then
        if grep -q "PORT=" "$HOME/premiumfoto/.env"; then
            sed -i "s/PORT=.*/PORT=3040/" "$HOME/premiumfoto/.env"
        else
            echo "PORT=3040" >> "$HOME/premiumfoto/.env"
        fi
        echo -e "${GREEN}✅ premiumfoto .env PORT=3040 olarak güncellendi${NC}"
    fi
fi

# aktas-market .env
if [ -f "$AKTAS_DIR/.env" ]; then
    if ! grep -q "PORT=3001" "$AKTAS_DIR/.env"; then
        if grep -q "PORT=" "$AKTAS_DIR/.env"; then
            sed -i "s/PORT=.*/PORT=3001/" "$AKTAS_DIR/.env"
        else
            echo "PORT=3001" >> "$AKTAS_DIR/.env"
        fi
        echo -e "${GREEN}✅ aktas-market .env PORT=3001 olarak güncellendi${NC}"
    fi
fi

# 5. Portların boş olduğunu doğrula
echo -e "${YELLOW}🔍 Portlar kontrol ediliyor...${NC}"
if sudo lsof -i:3040 > /dev/null 2>&1; then
    echo -e "${RED}❌ Port 3040 hala kullanımda!${NC}"
    sudo lsof -i:3040
    exit 1
fi

if sudo lsof -i:3001 > /dev/null 2>&1; then
    echo -e "${RED}❌ Port 3001 hala kullanımda!${NC}"
    sudo lsof -i:3001
    exit 1
fi

echo -e "${GREEN}✅ Portlar boş${NC}"

# 6. foto-ugur-app'i başlat
echo -e "${YELLOW}🚀 foto-ugur-app başlatılıyor (port 3040)...${NC}"
cd "$HOME/premiumfoto"
pm2 start npm --name "foto-ugur-app" -- start
sleep 3

# 7. aktas-market'i başlat
echo -e "${YELLOW}🚀 aktas-market başlatılıyor (port 3001)...${NC}"
if [ -f "$AKTAS_DIR/ecosystem-aktas-market.config.cjs" ]; then
    pm2 start "$AKTAS_DIR/ecosystem-aktas-market.config.cjs"
else
    # Eğer config yoksa oluştur
    cat > "$AKTAS_DIR/ecosystem-aktas-market.config.cjs" << PM2EOF
module.exports = {
  apps: [{
    name: 'aktas-market',
    script: 'npm',
    args: 'start',
    cwd: '$AKTAS_DIR',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    error_file: '$HOME/.pm2/logs/aktas-market-error.log',
    out_file: '$HOME/.pm2/logs/aktas-market-out.log',
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
    pm2 start "$AKTAS_DIR/ecosystem-aktas-market.config.cjs"
fi
sleep 3

# 8. PM2'ye kaydet
pm2 save

# 9. Durum kontrolü
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 10. Port kontrolü
echo -e "${YELLOW}🔍 Port durumları kontrol ediliyor...${NC}"
echo "Port 3040:"
sudo lsof -i:3040 | head -2 || echo "  Boş"
echo "Port 3001:"
sudo lsof -i:3001 | head -2 || echo "  Boş"

# 11. Nginx reload
echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
sudo nginx -t && sudo systemctl reload nginx
echo -e "${GREEN}✅ Nginx reload edildi${NC}"

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I http://localhost:3040"
echo "   curl -I http://localhost:3001"
echo "   pm2 logs foto-ugur-app --lines 10"
echo "   pm2 logs aktas-market --lines 10"

