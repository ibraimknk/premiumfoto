#!/bin/bash

# Rich Snippet Kontrol Script'i
# Kullanım: bash scripts/check-rich-snippets.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="${DOMAIN:-https://fotougur.com.tr}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Rich Snippet Kontrol Script'i               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Ana sayfa
echo -e "${YELLOW}1. Ana Sayfa:${NC}"
SCHEMA_COUNT=$(curl -s "$DOMAIN" 2>/dev/null | grep -o 'application/ld+json' | wc -l)
if [ "$SCHEMA_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Schema sayısı: $SCHEMA_COUNT${NC}"
    echo -e "${YELLOW}   Beklenen: 3-4 (Organization, LocalBusiness, WebSite, Review)${NC}"
else
    echo -e "${YELLOW}   ⚠️  Schema bulunamadı${NC}"
fi
echo ""

# Blog listesi
echo -e "${YELLOW}2. Blog Listesi:${NC}"
SCHEMA_COUNT=$(curl -s "$DOMAIN/blog" 2>/dev/null | grep -o 'application/ld+json' | wc -l)
if [ "$SCHEMA_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Schema sayısı: $SCHEMA_COUNT${NC}"
    echo -e "${YELLOW}   Beklenen: 1 (Blog)${NC}"
else
    echo -e "${YELLOW}   ⚠️  Schema bulunamadı${NC}"
fi
echo ""

# Blog yazısı (ilk blog slug'ını al)
echo -e "${YELLOW}3. Blog Yazısı:${NC}"
BLOG_SLUG=$(curl -s "$DOMAIN/blog" 2>/dev/null | grep -oP 'href="/blog/[^"]+"' | head -1 | sed 's/href="\/blog\///;s/"//' || echo "")
if [ ! -z "$BLOG_SLUG" ]; then
    SCHEMA_COUNT=$(curl -s "$DOMAIN/blog/$BLOG_SLUG" 2>/dev/null | grep -o 'application/ld+json' | wc -l)
    if [ "$SCHEMA_COUNT" -gt 0 ]; then
        echo -e "${GREEN}   ✅ Schema sayısı: $SCHEMA_COUNT (Blog: $BLOG_SLUG)${NC}"
        echo -e "${YELLOW}   Beklenen: 2 (BlogPosting, BreadcrumbList)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Schema bulunamadı${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Blog yazısı bulunamadı${NC}"
fi
echo ""

# Hizmet listesi
echo -e "${YELLOW}4. Hizmet Listesi:${NC}"
SCHEMA_COUNT=$(curl -s "$DOMAIN/hizmetler" 2>/dev/null | grep -o 'application/ld+json' | wc -l)
if [ "$SCHEMA_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Schema sayısı: $SCHEMA_COUNT${NC}"
    echo -e "${YELLOW}   Beklenen: 1 (ItemList)${NC}"
else
    echo -e "${YELLOW}   ⚠️  Schema bulunamadı${NC}"
fi
echo ""

# İletişim
echo -e "${YELLOW}5. İletişim:${NC}"
SCHEMA_COUNT=$(curl -s "$DOMAIN/iletisim" 2>/dev/null | grep -o 'application/ld+json' | wc -l)
if [ "$SCHEMA_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Schema sayısı: $SCHEMA_COUNT${NC}"
    echo -e "${YELLOW}   Beklenen: 1 (ContactPage)${NC}"
else
    echo -e "${YELLOW}   ⚠️  Schema bulunamadı${NC}"
fi
echo ""

# SSS
echo -e "${YELLOW}6. SSS:${NC}"
SCHEMA_COUNT=$(curl -s "$DOMAIN/sss" 2>/dev/null | grep -o 'application/ld+json' | wc -l)
if [ "$SCHEMA_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Schema sayısı: $SCHEMA_COUNT${NC}"
    echo -e "${YELLOW}   Beklenen: 1 (FAQPage)${NC}"
else
    echo -e "${YELLOW}   ⚠️  Schema bulunamadı${NC}"
fi
echo ""

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    ÖZET                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📋 Detaylı Kontrol:${NC}"
echo "   Google Rich Results Test: https://search.google.com/test/rich-results"
echo "   Schema.org Validator: https://validator.schema.org/"
echo ""
echo -e "${GREEN}✅ Kontrol tamamlandı!${NC}"

