#!/bin/bash

# Google Search Console API ile indexlenen blog URL'lerini bulma scripti
# Kullanım: bash scripts/run-google-index-check.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Google'da Indexlenen Blog URL'lerini Bulma${NC}"
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Python kontrolü
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}❌ Python bulunamadı!${NC}"
    exit 1
fi

PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi

# Virtual environment oluştur/kontrol et
VENV_DIR="venv"
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}📦 Python virtual environment oluşturuluyor...${NC}"
    $PYTHON_CMD -m venv "$VENV_DIR"
    echo -e "${GREEN}✅ Virtual environment oluşturuldu${NC}"
fi

# Virtual environment'ı aktifleştir
source "$VENV_DIR/bin/activate"

# Gerekli paketleri kontrol et ve kur
echo -e "${YELLOW}📦 Python paketleri kontrol ediliyor...${NC}"
REQUIRED_PACKAGES=(
    "google-auth"
    "google-auth-oauthlib"
    "google-auth-httplib2"
    "google-api-python-client"
    "beautifulsoup4"
    "requests"
)

MISSING_PACKAGES=()
for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! $PYTHON_CMD -c "import ${package//-/_}" 2>/dev/null; then
        MISSING_PACKAGES+=("$package")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}📦 Eksik paketler kuruluyor: ${MISSING_PACKAGES[*]}${NC}"
    pip install "${MISSING_PACKAGES[@]}"
fi

# client_secret.json kontrolü
if [ ! -f "client_secret.json" ]; then
    echo -e "${RED}❌ client_secret.json dosyası bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Google Cloud Console'dan OAuth credentials indirin ve client_secret.json olarak kaydedin${NC}"
    echo -e "${YELLOW}📚 Detaylar için: GOOGLE-SEARCH-CONSOLE-SETUP.md${NC}"
    exit 1
fi

# Parametreler
SITE_URL="${SITE_URL:-https://fotougur.com.tr/}"
SITEMAP="${SITEMAP:-https://fotougur.com.tr/sitemap.xml}"
OUTPUT_FILE="${OUTPUT_FILE:-blog_indexed_urls.csv}"
SLEEP="${SLEEP:-0.2}"
MAX_URLS="${MAX_URLS:-0}"

echo -e "${GREEN}✅ Tüm kontroller tamamlandı${NC}"
echo ""
echo -e "${BLUE}📋 Parametreler:${NC}"
echo -e "   Site URL: ${SITE_URL}"
echo -e "   Sitemap: ${SITEMAP}"
echo -e "   Çıktı: ${OUTPUT_FILE}"
echo -e "   Sleep: ${SLEEP}s"
echo -e "   Max URLs: ${MAX_URLS:-"Sınırsız"}"
echo ""

# Script'i çalıştır
echo -e "${BLUE}🔄 Google Search Console API ile URL'ler kontrol ediliyor...${NC}"
echo ""

# Virtual environment içindeki Python'u kullan
python google.py \
    --client-secret client_secret.json \
    --site-url "$SITE_URL" \
    --sitemap "$SITEMAP" \
    --sleep "$SLEEP" \
    --out "$OUTPUT_FILE" \
    ${MAX_URLS:+--max $MAX_URLS}

echo ""

# Blog URL'lerini filtrele
if [ -f "$OUTPUT_FILE" ]; then
    BLOG_OUTPUT="blog_urls_only.csv"
    echo -e "${YELLOW}📝 Blog URL'leri filtreleniyor...${NC}"
    
    # CSV başlığını ekle
    head -n 1 "$OUTPUT_FILE" > "$BLOG_OUTPUT"
    
    # Sadece /blog/ içeren URL'leri ekle
    grep "/blog/" "$OUTPUT_FILE" >> "$BLOG_OUTPUT" || true
    
    BLOG_COUNT=$(tail -n +2 "$BLOG_OUTPUT" | wc -l | tr -d ' ')
    
    echo -e "${GREEN}✅ ${BLOG_COUNT} blog URL'i bulundu${NC}"
    echo -e "${GREEN}✅ Blog URL'leri kaydedildi: ${BLOG_OUTPUT}${NC}"
    echo ""
    echo -e "${BLUE}💡 Şimdi bu URL'leri kullanarak blog oluşturabilirsiniz:${NC}"
    echo -e "   npm run regenerate-blogs"
else
    echo -e "${RED}❌ CSV dosyası oluşturulamadı!${NC}"
    exit 1
fi

