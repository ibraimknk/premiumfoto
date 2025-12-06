#!/bin/bash

# Foto Uğur - Güncelleme Script'i
# Kullanım: bash deploy-update.sh

set -e

# Renkler
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Değişkenler
APP_DIR="/var/www/foto-ugur"
PM2_APP_NAME="foto-ugur-app"

echo -e "${YELLOW}🔄 Uygulama güncelleniyor...${NC}"

cd ${APP_DIR}

# Git pull
if [ -d ".git" ]; then
    echo -e "${YELLOW}📥 Değişiklikler çekiliyor...${NC}"
    git pull origin main || git pull origin master
else
    echo "❌ Git repository bulunamadı!"
    exit 1
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

