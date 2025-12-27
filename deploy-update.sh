#!/bin/bash

# Foto Uğur - Güncelleme Script'i
# Kullanım: bash deploy-update.sh

set -e

# Renkler
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Değişkenler
# Mevcut dizini kullan (script'in çalıştığı dizin)
APP_DIR="${APP_DIR:-$(pwd)}"
PM2_APP_NAME="foto-ugur-app"

echo -e "${YELLOW}🔄 Uygulama güncelleniyor...${NC}"

# Eğer APP_DIR mevcut dizinden farklıysa, o dizine git
if [ "$(pwd)" != "${APP_DIR}" ] && [ "${APP_DIR}" != "$(pwd)" ]; then
    cd ${APP_DIR}
else
    # Mevcut dizinde çalış
    APP_DIR="$(pwd)"
    echo -e "${GREEN}✅ Mevcut dizin kullanılıyor: ${APP_DIR}${NC}"
fi

# Git pull
if [ -d ".git" ]; then
    echo -e "${YELLOW}📥 Değişiklikler çekiliyor...${NC}"
    git pull origin main || git pull origin master
else
    echo "❌ Git repository bulunamadı!"
    exit 1
fi

# .env dosyası kontrolü (GEMINI_API_KEY)
if [ -f ".env" ]; then
    if ! grep -q "GEMINI_API_KEY" .env; then
        echo "GEMINI_API_KEY=\"AIzaSyB06DSrZjgcCqgA_FOxJf-1JyIESlbwLqQ\"" >> .env
        echo -e "${GREEN}✅ GEMINI_API_KEY .env dosyasına eklendi${NC}"
    fi
fi

# Bağımlılıkları güncelle
echo -e "${YELLOW}📦 Bağımlılıklar güncelleniyor...${NC}"
npm ci --production=false

# Prisma client güncelle
echo -e "${YELLOW}🗄️  Prisma client güncelleniyor...${NC}"
npx prisma generate

# Migration (eğer varsa)
echo -e "${YELLOW}🗄️  Veritabanı migration'ları uygulanıyor...${NC}"
npx prisma db push --accept-data-loss || true

# Build
echo -e "${YELLOW}🏗️  Production build oluşturuluyor...${NC}"
npm run build

# PM2 restart
echo -e "${YELLOW}🔄 PM2 uygulaması yeniden başlatılıyor...${NC}"
pm2 restart ${PM2_APP_NAME}

echo -e "${GREEN}✅ Güncelleme tamamlandı!${NC}"
pm2 logs ${PM2_APP_NAME} --lines 20

