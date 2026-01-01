#!/bin/bash

# dugunkarem.com sertifika dosyalarını manuel olarak kontrol et ve symlink oluştur

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LIVE_DIR="/etc/letsencrypt/live/dugunkarem.com"
ARCHIVE_DIR="/etc/letsencrypt/archive/dugunkarem.com"

echo -e "${YELLOW}🔍 dugunkarem.com sertifika dosyaları aranıyor...${NC}"

# 1. Archive dizinini kontrol et
echo ""
echo -e "${YELLOW}1️⃣ Archive dizini kontrol ediliyor:${NC}"
if [ -d "$ARCHIVE_DIR" ]; then
    echo -e "${GREEN}✅ Archive dizini var${NC}"
    sudo ls -la "$ARCHIVE_DIR"
else
    echo -e "${RED}❌ Archive dizini yok: $ARCHIVE_DIR${NC}"
    echo -e "${YELLOW}💡 Archive dizinini oluşturuyoruz...${NC}"
    sudo mkdir -p "$ARCHIVE_DIR"
fi

# 2. Live dizinini kontrol et
echo ""
echo -e "${YELLOW}2️⃣ Live dizini kontrol ediliyor:${NC}"
if [ -d "$LIVE_DIR" ]; then
    echo -e "${GREEN}✅ Live dizini var${NC}"
    sudo ls -la "$LIVE_DIR"
else
    echo -e "${RED}❌ Live dizini yok: $LIVE_DIR${NC}"
    echo -e "${YELLOW}💡 Live dizinini oluşturuyoruz...${NC}"
    sudo mkdir -p "$LIVE_DIR"
fi

# 3. Certbot renewal config'ini kontrol et
echo ""
echo -e "${YELLOW}3️⃣ Certbot renewal config kontrol ediliyor:${NC}"
RENEWAL_CONFIG="/etc/letsencrypt/renewal/dugunkarem.com.conf"
if [ -f "$RENEWAL_CONFIG" ]; then
    echo -e "${GREEN}✅ Renewal config var${NC}"
    sudo grep -E "archive_dir|cert|privkey|chain|fullchain" "$RENEWAL_CONFIG" | head -10
else
    echo -e "${RED}❌ Renewal config yok: $RENEWAL_CONFIG${NC}"
fi

# 4. Tüm letsencrypt dizinini kontrol et
echo ""
echo -e "${YELLOW}4️⃣ Letsencrypt dizini kontrol ediliyor:${NC}"
sudo find /etc/letsencrypt -name "*dugunkarem*" -type f 2>/dev/null | head -10

# 5. Eğer dosyalar yoksa, certbot install komutunu kullan
echo ""
echo -e "${YELLOW}5️⃣ Certbot install komutu çalıştırılıyor...${NC}"
if sudo certbot install --cert-name dugunkarem.com --nginx 2>&1 | tee /tmp/certbot-install.log; then
    echo -e "${GREEN}✅ Certbot install başarılı${NC}"
else
    echo -e "${YELLOW}⚠️  Certbot install başarısız, manuel kontrol gerekebilir${NC}"
    cat /tmp/certbot-install.log
fi

# 6. Son kontrol
echo ""
echo -e "${YELLOW}6️⃣ Son kontrol:${NC}"
if [ -f "$LIVE_DIR/fullchain.pem" ] && [ -f "$LIVE_DIR/privkey.pem" ]; then
    echo -e "${GREEN}✅ Sertifika dosyaları hazır!${NC}"
    sudo ls -la "$LIVE_DIR"
    
    echo ""
    echo -e "${YELLOW}📋 Sertifika bilgileri:${NC}"
    sudo openssl x509 -in "$LIVE_DIR/fullchain.pem" -noout -subject -dates 2>/dev/null | head -2
else
    echo -e "${RED}❌ Sertifika dosyaları hala bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Manuel olarak oluşturmanız gerekebilir${NC}"
fi

