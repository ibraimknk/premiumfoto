#!/bin/bash

# dugunkarem.com sertifikasının gerçek yerini bul

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 dugunkarem.com sertifikası aranıyor...${NC}"

# 1. Certbot certificates çıktısını kontrol et
echo ""
echo -e "${YELLOW}1️⃣ Certbot sertifikaları:${NC}"
sudo certbot certificates 2>/dev/null | grep -A 10 "dugunkarem.com" || echo "Sertifika bulunamadı"

# 2. /etc/letsencrypt/live/ dizinini kontrol et
echo ""
echo -e "${YELLOW}2️⃣ /etc/letsencrypt/live/ dizini:${NC}"
sudo ls -la /etc/letsencrypt/live/ 2>/dev/null | grep -E "dugunkarem|total" || echo "Dizin bulunamadı"

# 3. Sertifika dosyalarını ara
echo ""
echo -e "${YELLOW}3️⃣ Sertifika dosyaları aranıyor:${NC}"
sudo find /etc/letsencrypt -name "*dugunkarem*" -type f 2>/dev/null | head -10

# 4. Symlink'leri kontrol et
echo ""
echo -e "${YELLOW}4️⃣ Symlink'ler kontrol ediliyor:${NC}"
if [ -L "/etc/letsencrypt/live/dugunkarem.com" ]; then
    echo -e "${GREEN}✅ Symlink var${NC}"
    ls -la /etc/letsencrypt/live/dugunkarem.com
    echo ""
    echo "Hedef:"
    readlink -f /etc/letsencrypt/live/dugunkarem.com
else
    echo -e "${RED}❌ Symlink yok${NC}"
fi

# 5. Archive dizinini kontrol et
echo ""
echo -e "${YELLOW}5️⃣ /etc/letsencrypt/archive/ dizini:${NC}"
sudo ls -la /etc/letsencrypt/archive/ 2>/dev/null | grep -E "dugunkarem|total" || echo "Dizin bulunamadı"

# 6. Sertifikayı yeniden oluşturma önerisi
echo ""
echo -e "${YELLOW}6️⃣ Öneri:${NC}"
echo "   Sertifika dosyaları bulunamadı. Sertifikayı yeniden oluşturun:"
echo "   sudo certbot --nginx -d dugunkarem.com -d dugunkarem.com.tr --expand --force-renewal"

