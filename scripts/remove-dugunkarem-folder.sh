#!/bin/bash

# dugunkarem klasörünü ve ilgili tüm dosyaları sil

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DUGUNKAREM_DIR="/home/ibrahim/dugunkarem"
DUGUNKAREM_CONFIG="/etc/nginx/sites-available/dugunkarem"
DUGUNKAREM_ENABLED="/etc/nginx/sites-enabled/dugunkarem"
DUGUNKAREM_3040_CONFIG="/etc/nginx/sites-available/dugunkarem-3040"
DUGUNKAREM_3040_ENABLED="/etc/nginx/sites-enabled/dugunkarem-3040"
PM2_APP_NAME="dugunkarem-app"

echo -e "${YELLOW}🗑️  dugunkarem klasörü ve ilgili dosyalar siliniyor...${NC}"

# PM2 uygulamasını durdur ve sil
if pm2 list | grep -q "${PM2_APP_NAME}"; then
    echo -e "${YELLOW}🛑 PM2 uygulaması durduruluyor...${NC}"
    pm2 stop "${PM2_APP_NAME}" || true
    pm2 delete "${PM2_APP_NAME}" || true
    pm2 save || true
    echo -e "${GREEN}✅ PM2 uygulaması silindi${NC}"
else
    echo -e "${YELLOW}⚠️  PM2 uygulaması bulunamadı${NC}"
fi

# Nginx config'lerini devre dışı bırak ve sil
if [ -L "$DUGUNKAREM_ENABLED" ]; then
    echo -e "${YELLOW}🗑️  Nginx config devre dışı bırakılıyor...${NC}"
    sudo rm -f "$DUGUNKAREM_ENABLED"
    echo -e "${GREEN}✅ Nginx config devre dışı bırakıldı${NC}"
fi

if [ -f "$DUGUNKAREM_CONFIG" ]; then
    echo -e "${YELLOW}🗑️  Nginx config dosyası siliniyor...${NC}"
    sudo rm -f "$DUGUNKAREM_CONFIG"
    echo -e "${GREEN}✅ Nginx config dosyası silindi${NC}"
fi

if [ -L "$DUGUNKAREM_3040_ENABLED" ]; then
    echo -e "${YELLOW}🗑️  Nginx dugunkarem-3040 config devre dışı bırakılıyor...${NC}"
    sudo rm -f "$DUGUNKAREM_3040_ENABLED"
    echo -e "${GREEN}✅ Nginx dugunkarem-3040 config devre dışı bırakıldı${NC}"
fi

if [ -f "$DUGUNKAREM_3040_CONFIG" ]; then
    echo -e "${YELLOW}🗑️  Nginx dugunkarem-3040 config dosyası siliniyor...${NC}"
    sudo rm -f "$DUGUNKAREM_3040_CONFIG"
    echo -e "${GREEN}✅ Nginx dugunkarem-3040 config dosyası silindi${NC}"
fi

# dugunkarem klasörünü sil
if [ -d "$DUGUNKAREM_DIR" ]; then
    echo -e "${YELLOW}🗑️  dugunkarem klasörü siliniyor...${NC}"
    rm -rf "$DUGUNKAREM_DIR"
    echo -e "${GREEN}✅ dugunkarem klasörü silindi${NC}"
else
    echo -e "${YELLOW}⚠️  dugunkarem klasörü bulunamadı${NC}"
fi

# Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ dugunkarem klasörü ve ilgili dosyalar başarıyla silindi!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol:${NC}"
echo "   ls -la /home/ibrahim/ | grep dugunkarem"
echo "   pm2 list | grep dugunkarem"
echo "   sudo ls -la /etc/nginx/sites-available/ | grep dugunkarem"
echo "   sudo ls -la /etc/nginx/sites-enabled/ | grep dugunkarem"

