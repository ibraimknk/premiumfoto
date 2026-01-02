#!/bin/bash

# Google'da indexlenen blog sayfalarını bulup otomatik blog oluşturma scripti
# Kullanım: bash scripts/regenerate-blogs-manual.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Google'dan Indexlenen Blog Sayfaları İçin Otomatik Blog Oluşturma${NC}"
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Gerekli paketleri kontrol et
echo -e "${YELLOW}📦 Gerekli paketler kontrol ediliyor...${NC}"
if ! npm list cheerio &>/dev/null; then
    echo -e "${YELLOW}📦 cheerio paketi kuruluyor...${NC}"
    npm install cheerio
fi

# .env dosyasını kontrol et
echo -e "${YELLOW}🔍 .env dosyası kontrol ediliyor...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env dosyası bulunamadı!${NC}"
    exit 1
fi

# GEMINI_API_KEY kontrolü
if ! grep -q "GEMINI_API_KEY" .env; then
    echo -e "${YELLOW}⚠️  GEMINI_API_KEY .env dosyasında bulunamadı${NC}"
    echo -e "${YELLOW}💡 .env dosyasına GEMINI_API_KEY ekleyin${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Tüm kontroller tamamlandı${NC}"
echo ""

# Script'i çalıştır
echo -e "${BLUE}🔄 Blog'lar oluşturuluyor...${NC}"
echo ""

npm run regenerate-blogs

echo ""
echo -e "${GREEN}✅ İşlem tamamlandı!${NC}"

