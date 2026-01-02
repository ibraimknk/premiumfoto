#!/bin/bash

# Veritabanı yedeklerini kontrol et

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DB_PATH="$HOME/premiumfoto/prisma/dev.db"
BACKUP_DIR="$HOME/premiumfoto/backups"
BACKUP_DIR_ALT="$HOME/backup"

echo -e "${YELLOW}🔍 Veritabanı yedekleri kontrol ediliyor...${NC}"

# 1. Veritabanı dosyası var mı?
echo -e "${YELLOW}1️⃣ Veritabanı dosyası kontrol ediliyor...${NC}"
if [ -f "$DB_PATH" ]; then
    DB_SIZE=$(du -h "$DB_PATH" | cut -f1)
    DB_DATE=$(stat -c %y "$DB_PATH" 2>/dev/null || stat -f "%Sm" "$DB_PATH" 2>/dev/null || echo "bilinmiyor")
    echo -e "${GREEN}✅ Veritabanı mevcut: $DB_PATH${NC}"
    echo -e "${YELLOW}   Boyut: $DB_SIZE${NC}"
    echo -e "${YELLOW}   Son değişiklik: $DB_DATE${NC}"
    
    # Blog kayıt sayısı
    BLOG_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
    echo -e "${YELLOW}   Blog kayıt sayısı: $BLOG_COUNT${NC}"
else
    echo -e "${RED}❌ Veritabanı bulunamadı: $DB_PATH${NC}"
fi
echo ""

# 2. Yedek dizinlerini kontrol et
echo -e "${YELLOW}2️⃣ Yedek dizinleri kontrol ediliyor...${NC}"

BACKUP_FOUND=false

# premiumfoto/backups
if [ -d "$BACKUP_DIR" ]; then
    BACKUP_COUNT=$(find "$BACKUP_DIR" -name "*.db" -o -name "*.sqlite" -o -name "*.sql" 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Yedek dizini mevcut: $BACKUP_DIR${NC}"
        echo -e "${YELLOW}   Yedek dosya sayısı: $BACKUP_COUNT${NC}"
        echo -e "${YELLOW}   Son yedekler:${NC}"
        find "$BACKUP_DIR" -name "*.db" -o -name "*.sqlite" -o -name "*.sql" 2>/dev/null | head -5 | while read backup; do
            BACKUP_SIZE=$(du -h "$backup" | cut -f1)
            BACKUP_DATE=$(stat -c %y "$backup" 2>/dev/null || stat -f "%Sm" "$backup" 2>/dev/null || echo "bilinmiyor")
            echo -e "${YELLOW}     - $(basename $backup) ($BACKUP_SIZE, $BACKUP_DATE)${NC}"
        done
        BACKUP_FOUND=true
    fi
fi

# ~/backup
if [ -d "$BACKUP_DIR_ALT" ]; then
    BACKUP_COUNT=$(find "$BACKUP_DIR_ALT" -name "*dev.db*" -o -name "*premiumfoto*" 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Yedek dizini mevcut: $BACKUP_DIR_ALT${NC}"
        echo -e "${YELLOW}   Yedek dosya sayısı: $BACKUP_COUNT${NC}"
        find "$BACKUP_DIR_ALT" -name "*dev.db*" -o -name "*premiumfoto*" 2>/dev/null | head -5 | while read backup; do
            BACKUP_SIZE=$(du -h "$backup" | cut -f1)
            BACKUP_DATE=$(stat -c %y "$backup" 2>/dev/null || stat -f "%Sm" "$backup" 2>/dev/null || echo "bilinmiyor")
            echo -e "${YELLOW}     - $(basename $backup) ($BACKUP_SIZE, $BACKUP_DATE)${NC}"
        done
        BACKUP_FOUND=true
    fi
fi

# Tüm sistemde dev.db yedekleri ara
echo -e "${YELLOW}3️⃣ Sistem genelinde yedek aranıyor...${NC}"
SYSTEM_BACKUPS=$(find ~ -name "*dev.db*" -o -name "*premiumfoto*.db" 2>/dev/null | grep -v "$DB_PATH" | head -10)
if [ ! -z "$SYSTEM_BACKUPS" ]; then
    echo -e "${GREEN}✅ Sistem genelinde yedekler bulundu:${NC}"
    echo "$SYSTEM_BACKUPS" | while read backup; do
        BACKUP_SIZE=$(du -h "$backup" | cut -f1)
        BACKUP_DATE=$(stat -c %y "$backup" 2>/dev/null || stat -f "%Sm" "$backup" 2>/dev/null || echo "bilinmiyor")
        echo -e "${YELLOW}   - $backup ($BACKUP_SIZE, $BACKUP_DATE)${NC}"
    done
    BACKUP_FOUND=true
else
    echo -e "${RED}❌ Sistem genelinde yedek bulunamadı${NC}"
fi

if [ "$BACKUP_FOUND" = false ]; then
    echo -e "${RED}❌ Hiç yedek bulunamadı!${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Yedek oluşturma komutu:${NC}"
echo "   sqlite3 $DB_PATH \".backup '$BACKUP_DIR/dev.db.backup.\$(date +%Y%m%d_%H%M%S)'\""

