#!/bin/bash

# Veritabanı yedeğini geri yükle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DB_PATH="$HOME/premiumfoto/prisma/dev.db"
BACKUP_FILE="$HOME/premiumfoto/prisma/prisma/dev.db"

echo -e "${YELLOW}🔧 Veritabanı yedeği geri yükleniyor...${NC}"

# 1. Yedek dosyası var mı?
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Yedek dosyası bulunamadı: $BACKUP_FILE${NC}"
    echo -e "${YELLOW}💡 Mevcut yedekleri kontrol edin:${NC}"
    find ~ -name "*dev.db*" -type f 2>/dev/null | grep -v "$DB_PATH" | head -10
    exit 1
fi

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
BACKUP_DATE=$(stat -c %y "$BACKUP_FILE" 2>/dev/null || stat -f "%Sm" "$BACKUP_FILE" 2>/dev/null || echo "bilinmiyor")

echo -e "${GREEN}✅ Yedek dosyası bulundu: $BACKUP_FILE${NC}"
echo -e "${YELLOW}   Boyut: $BACKUP_SIZE${NC}"
echo -e "${YELLOW}   Tarih: $BACKUP_DATE${NC}"

# 2. Mevcut veritabanını yedekle (eğer varsa)
if [ -f "$DB_PATH" ]; then
    CURRENT_SIZE=$(du -h "$DB_PATH" | cut -f1)
    echo -e "${YELLOW}⚠️  Mevcut veritabanı var (Boyut: $CURRENT_SIZE)${NC}"
    
    # Yedek dizini oluştur
    mkdir -p "$HOME/premiumfoto/backups"
    
    # Mevcut veritabanını yedekle
    BACKUP_CURRENT="$HOME/premiumfoto/backups/dev.db.current.$(date +%Y%m%d_%H%M%S)"
    cp "$DB_PATH" "$BACKUP_CURRENT"
    echo -e "${GREEN}✅ Mevcut veritabanı yedeklendi: $BACKUP_CURRENT${NC}"
fi

# 3. Yedek dosyasını geri yükle
echo -e "${YELLOW}📥 Yedek dosyası geri yükleniyor...${NC}"

# Dizin yapısını kontrol et
DB_DIR=$(dirname "$DB_PATH")
mkdir -p "$DB_DIR"

# Yedek dosyasını kopyala
cp "$BACKUP_FILE" "$DB_PATH"
echo -e "${GREEN}✅ Veritabanı geri yüklendi${NC}"

# 4. İzinleri düzelt
chmod 644 "$DB_PATH"
echo -e "${GREEN}✅ İzinler düzeltildi${NC}"

# 5. Veritabanını kontrol et
echo -e "${YELLOW}🔍 Veritabanı kontrol ediliyor...${NC}"

RESTORED_SIZE=$(du -h "$DB_PATH" | cut -f1)
echo -e "${GREEN}✅ Geri yüklenen veritabanı boyutu: $RESTORED_SIZE${NC}"

# Tabloları kontrol et
TABLES=$(sqlite3 "$DB_PATH" ".tables" 2>/dev/null || echo "")
if [ ! -z "$TABLES" ]; then
    echo -e "${GREEN}✅ Tablolar bulundu:${NC}"
    echo "$TABLES" | tr ' ' '\n' | while read table; do
        if [ ! -z "$table" ]; then
            COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM $table;" 2>/dev/null || echo "0")
            echo -e "${YELLOW}   - $table: $COUNT kayıt${NC}"
        fi
    done
else
    echo -e "${RED}❌ Tablo bulunamadı!${NC}"
fi

# Blog kayıt sayısı
BLOG_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
echo -e "${YELLOW}📊 Blog kayıt sayısı: $BLOG_COUNT${NC}"

# 6. Prisma client'ı yeniden oluştur
echo -e "${YELLOW}🔄 Prisma client yeniden oluşturuluyor...${NC}"
cd "$HOME/premiumfoto"
npx prisma generate
echo -e "${GREEN}✅ Prisma client oluşturuldu${NC}"

# 7. PM2'yi restart et
echo -e "${YELLOW}🔄 PM2 uygulaması yeniden başlatılıyor...${NC}"
pm2 restart foto-ugur-app --update-env
echo -e "${GREEN}✅ PM2 restart edildi${NC}"

echo ""
echo -e "${GREEN}✅ Veritabanı geri yükleme tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol komutları:${NC}"
echo "   sqlite3 $DB_PATH \"SELECT COUNT(*) FROM BlogPost;\""
echo "   pm2 logs foto-ugur-app --lines 20"

