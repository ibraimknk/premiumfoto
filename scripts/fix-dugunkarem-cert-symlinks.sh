#!/bin/bash

# dugunkarem.com sertifika symlink'lerini oluştur

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LIVE_DIR="/etc/letsencrypt/live/dugunkarem.com"
ARCHIVE_DIR="/etc/letsencrypt/archive/dugunkarem.com"

echo -e "${YELLOW}🔗 dugunkarem.com sertifika symlink'leri oluşturuluyor...${NC}"

# Archive dizinindeki dosyaları kontrol et
if [ ! -d "$ARCHIVE_DIR" ]; then
    echo -e "${RED}❌ Archive dizini bulunamadı: $ARCHIVE_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Archive dizinindeki dosyalar:${NC}"
sudo ls -la "$ARCHIVE_DIR"

# En son sertifika versiyonunu bul
LATEST_CERT=$(sudo ls -t "$ARCHIVE_DIR"/cert*.pem 2>/dev/null | head -1)
LATEST_KEY=$(sudo ls -t "$ARCHIVE_DIR"/privkey*.pem 2>/dev/null | head -1)
LATEST_CHAIN=$(sudo ls -t "$ARCHIVE_DIR"/chain*.pem 2>/dev/null | head -1)
LATEST_FULLCHAIN=$(sudo ls -t "$ARCHIVE_DIR"/fullchain*.pem 2>/dev/null | head -1)

if [ -z "$LATEST_CERT" ] || [ -z "$LATEST_KEY" ] || [ -z "$LATEST_FULLCHAIN" ]; then
    echo -e "${RED}❌ Sertifika dosyaları archive dizininde bulunamadı!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Sertifika dosyaları bulundu${NC}"

# Live dizinini oluştur
sudo mkdir -p "$LIVE_DIR"

# Symlink'leri oluştur
echo -e "${YELLOW}🔗 Symlink'ler oluşturuluyor...${NC}"

sudo ln -sf "$(basename $LATEST_CERT)" "$LIVE_DIR/cert.pem"
sudo ln -sf "$(basename $LATEST_KEY)" "$LIVE_DIR/privkey.pem"
sudo ln -sf "$(basename $LATEST_CHAIN)" "$LIVE_DIR/chain.pem"
sudo ln -sf "$(basename $LATEST_FULLCHAIN)" "$LIVE_DIR/fullchain.pem"

# Symlink'lerin doğru olduğunu kontrol et
echo -e "${YELLOW}✅ Symlink'ler oluşturuldu:${NC}"
sudo ls -la "$LIVE_DIR"

# Dosyaların gerçekten var olduğunu kontrol et
if [ -f "$LIVE_DIR/fullchain.pem" ] && [ -f "$LIVE_DIR/privkey.pem" ]; then
    echo -e "${GREEN}✅ Sertifika dosyaları hazır!${NC}"
    
    # Sertifika bilgilerini göster
    echo ""
    echo -e "${YELLOW}📋 Sertifika bilgileri:${NC}"
    sudo openssl x509 -in "$LIVE_DIR/fullchain.pem" -noout -subject -dates 2>/dev/null | head -2
    
    echo ""
    echo -e "${YELLOW}📋 Sertifika içindeki domain'ler:${NC}"
    sudo openssl x509 -in "$LIVE_DIR/fullchain.pem" -noout -text 2>/dev/null | grep -A 2 "Subject Alternative Name" || sudo openssl x509 -in "$LIVE_DIR/fullchain.pem" -noout -text 2>/dev/null | grep "DNS:"
else
    echo -e "${RED}❌ Symlink'ler oluşturulamadı!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Symlink'ler başarıyla oluşturuldu!${NC}"
echo -e "${YELLOW}💡 Şimdi Nginx'i reload edin:${NC}"
echo "   sudo nginx -t && sudo systemctl reload nginx"

