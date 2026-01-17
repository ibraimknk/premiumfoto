#!/bin/bash

# Tüm blog'larda rich snippet kontrolü
# Kullanım: bash scripts/check-blog-rich-snippets.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="${DOMAIN:-https://fotougur.com.tr}"
APP_DIR="${APP_DIR:-$HOME/premiumfoto}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Tüm Blog'larda Rich Snippet Kontrolü          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

cd "$APP_DIR"

# Veritabanından blog slug'larını al
echo -e "${YELLOW}📋 Veritabanından blog'lar çekiliyor...${NC}"

BLOG_SLUGS=$(sqlite3 prisma/dev.db "SELECT slug FROM BlogPost WHERE isPublished = 1 AND publishedAt IS NOT NULL LIMIT 10;" 2>/dev/null || echo "")

if [ -z "$BLOG_SLUGS" ]; then
    echo -e "${RED}❌ Blog bulunamadı veya veritabanı hatası${NC}"
    exit 1
fi

BLOG_COUNT=$(echo "$BLOG_SLUGS" | wc -l)
echo -e "${GREEN}✅ $BLOG_COUNT blog bulundu${NC}"
echo ""

# Her blog için kontrol et
SUCCESS_COUNT=0
FAIL_COUNT=0

echo "$BLOG_SLUGS" | while read slug; do
    if [ -z "$slug" ]; then
        continue
    fi
    
    URL="$DOMAIN/blog/$slug"
    echo -e "${YELLOW}🔍 Kontrol ediliyor: $slug${NC}"
    
    # Schema sayısını kontrol et
    SCHEMA_COUNT=$(curl -s "$URL" 2>/dev/null | grep -o 'application/ld+json' | wc -l)
    
    if [ "$SCHEMA_COUNT" -ge 2 ]; then
        echo -e "${GREEN}   ✅ Schema sayısı: $SCHEMA_COUNT (BlogPosting + BreadcrumbList)${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}   ❌ Schema sayısı: $SCHEMA_COUNT (Beklenen: 2+)${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # BlogPosting schema'sını kontrol et
    HAS_ARTICLE=$(curl -s "$URL" 2>/dev/null | grep -o '"@type":"BlogPosting"' | wc -l)
    if [ "$HAS_ARTICLE" -gt 0 ]; then
        echo -e "${GREEN}   ✅ BlogPosting schema mevcut${NC}"
    else
        echo -e "${RED}   ❌ BlogPosting schema bulunamadı${NC}"
    fi
    
    # BreadcrumbList schema'sını kontrol et
    HAS_BREADCRUMB=$(curl -s "$URL" 2>/dev/null | grep -o '"@type":"BreadcrumbList"' | wc -l)
    if [ "$HAS_BREADCRUMB" -gt 0 ]; then
        echo -e "${GREEN}   ✅ BreadcrumbList schema mevcut${NC}"
    else
        echo -e "${RED}   ❌ BreadcrumbList schema bulunamadı${NC}"
    fi
    
    echo ""
done

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    ÖZET                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Başarılı: $SUCCESS_COUNT blog${NC}"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ Başarısız: $FAIL_COUNT blog${NC}"
fi
echo ""
echo -e "${YELLOW}💡 Not: Tüm blog'lar aynı component'i kullanır (app/(public)/blog/[slug]/page.tsx)${NC}"
echo -e "${YELLOW}   Bu yüzden tüm blog'lara otomatik olarak rich snippet eklenir.${NC}"
echo ""

