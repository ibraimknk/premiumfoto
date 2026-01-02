#!/bin/bash

# SQLite veritabanı izinlerini düzeltme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DB_PATH="$HOME/premiumfoto/prisma/dev.db"
DB_DIR="$HOME/premiumfoto/prisma"

echo -e "${BLUE}🔧 Veritabanı izinleri düzeltiliyor...${NC}"
echo ""

# Veritabanı dosyasını kontrol et
if [ ! -f "$DB_PATH" ]; then
    echo -e "${RED}❌ Veritabanı dosyası bulunamadı: ${DB_PATH}${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Mevcut izinler:${NC}"
ls -la "$DB_PATH"
echo ""

# İzinleri düzelt
echo -e "${YELLOW}🔧 İzinler düzeltiliyor...${NC}"

# Veritabanı dizinine yazma izni ver
sudo chmod 755 "$DB_DIR"
echo -e "${GREEN}✅ Dizin izinleri düzeltildi${NC}"

# Veritabanı dosyasına yazma izni ver
sudo chmod 664 "$DB_PATH"
echo -e "${GREEN}✅ Dosya izinleri düzeltildi${NC}"

# Kullanıcıya sahiplik ver
sudo chown $USER:$USER "$DB_PATH"
sudo chown $USER:$USER "$DB_DIR"
echo -e "${GREEN}✅ Sahiplik düzeltildi${NC}"

# Veritabanı dizinindeki tüm dosyalara izin ver
sudo chmod 664 "$DB_DIR"/*.db* 2>/dev/null || true
sudo chown $USER:$USER "$DB_DIR"/*.db* 2>/dev/null || true

echo ""
echo -e "${YELLOW}📋 Yeni izinler:${NC}"
ls -la "$DB_PATH"
echo ""

# PM2'yi yeniden başlat
echo -e "${YELLOW}🔄 PM2 yeniden başlatılıyor...${NC}"
pm2 restart foto-ugur-app
echo -e "${GREEN}✅ PM2 yeniden başlatıldı${NC}"
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Veritabanı İzinleri Düzeltildi!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}💡 Şimdi admin panelinden blog oluşturmayı tekrar deneyin.${NC}"
echo ""

