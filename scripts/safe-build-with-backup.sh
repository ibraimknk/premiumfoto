#!/bin/bash

# Güvenli Build Script - Veritabanı Yedekleme ile
# Kullanım: bash scripts/safe-build-with-backup.sh

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Değişkenler
APP_DIR="${APP_DIR:-$HOME/premiumfoto}"
DB_PATH="$APP_DIR/prisma/dev.db"
BACKUP_DIR="$APP_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/dev.db.backup.$TIMESTAMP"
PM2_APP_NAME="foto-ugur-app"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Güvenli Build - Veritabanı Yedekleme ile          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Dizin kontrolü
echo -e "${YELLOW}1️⃣  Dizin kontrolü...${NC}"
if [ ! -d "$APP_DIR" ]; then
    echo -e "${RED}❌ Uygulama dizini bulunamadı: $APP_DIR${NC}"
    exit 1
fi
cd "$APP_DIR"
echo -e "${GREEN}✅ Dizin: $APP_DIR${NC}"
echo ""

# 2. Veritabanı yedekleme
echo -e "${YELLOW}2️⃣  Veritabanı yedekleniyor...${NC}"
if [ -f "$DB_PATH" ]; then
    # Yedek dizini oluştur
    mkdir -p "$BACKUP_DIR"
    
    # Veritabanı boyutunu kontrol et
    DB_SIZE=$(du -h "$DB_PATH" | cut -f1)
    echo -e "${YELLOW}   Mevcut veritabanı boyutu: $DB_SIZE${NC}"
    
    # Blog kayıt sayısını kontrol et
    BLOG_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
    echo -e "${YELLOW}   Blog kayıt sayısı: $BLOG_COUNT${NC}"
    
    # Yedek oluştur
    sqlite3 "$DB_PATH" ".backup '$BACKUP_FILE'" 2>/dev/null || cp "$DB_PATH" "$BACKUP_FILE"
    
    if [ -f "$BACKUP_FILE" ]; then
        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo -e "${GREEN}✅ Yedek oluşturuldu: $BACKUP_FILE${NC}"
        echo -e "${GREEN}   Yedek boyutu: $BACKUP_SIZE${NC}"
    else
        echo -e "${RED}❌ Yedek oluşturulamadı!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Veritabanı dosyası bulunamadı, yeni oluşturulacak${NC}"
fi
echo ""

# 3. Git pull
echo -e "${YELLOW}3️⃣  Git değişiklikleri çekiliyor...${NC}"
if [ -d ".git" ]; then
    git pull origin main || git pull origin master
    echo -e "${GREEN}✅ Git pull tamamlandı${NC}"
else
    echo -e "${RED}❌ Git repository bulunamadı!${NC}"
    exit 1
fi
echo ""

# 4. Bağımlılıkları güncelle
echo -e "${YELLOW}4️⃣  Bağımlılıklar güncelleniyor...${NC}"
npm ci --production=false || npm install
echo -e "${GREEN}✅ Bağımlılıklar güncellendi${NC}"
echo ""

# 5. Prisma client güncelle
echo -e "${YELLOW}5️⃣  Prisma client güncelleniyor...${NC}"
npx prisma generate
echo -e "${GREEN}✅ Prisma client güncellendi${NC}"
echo ""

# 6. Veritabanı migration (data-loss olmadan)
echo -e "${YELLOW}6️⃣  Veritabanı migration kontrol ediliyor...${NC}"
# Sadece schema değişikliklerini uygula, veri kaybına izin verme
npx prisma db push --skip-generate || {
    echo -e "${YELLOW}⚠️  Migration hatası, devam ediliyor...${NC}"
}
echo ""

# 7. Build
echo -e "${YELLOW}7️⃣  Production build oluşturuluyor...${NC}"
if npm run build; then
    echo -e "${GREEN}✅ Build başarılı${NC}"
else
    echo -e "${RED}❌ Build başarısız!${NC}"
    echo -e "${YELLOW}🔄 Veritabanı geri yükleniyor...${NC}"
    
    # Veritabanını geri yükle
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$DB_PATH"
        chmod 644 "$DB_PATH"
        echo -e "${GREEN}✅ Veritabanı geri yüklendi${NC}"
    fi
    
    exit 1
fi
echo ""

# 8. Veritabanı kontrolü (blog kayıtları)
echo -e "${YELLOW}8️⃣  Veritabanı kontrol ediliyor...${NC}"
if [ -f "$DB_PATH" ]; then
    NEW_BLOG_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
    echo -e "${YELLOW}   Yeni blog kayıt sayısı: $NEW_BLOG_COUNT${NC}"
    
    if [ "$NEW_BLOG_COUNT" -lt "$BLOG_COUNT" ] && [ "$BLOG_COUNT" -gt "0" ]; then
        echo -e "${RED}⚠️  UYARI: Blog kayıt sayısı azaldı! ($BLOG_COUNT -> $NEW_BLOG_COUNT)${NC}"
        echo -e "${YELLOW}   Veritabanı geri yükleniyor...${NC}"
        
        # Veritabanını geri yükle
        cp "$BACKUP_FILE" "$DB_PATH"
        chmod 644 "$DB_PATH"
        
        # Prisma client'ı yeniden oluştur
        npx prisma generate
        
        echo -e "${GREEN}✅ Veritabanı geri yüklendi${NC}"
    else
        echo -e "${GREEN}✅ Blog kayıtları korundu${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Veritabanı dosyası bulunamadı${NC}"
fi
echo ""

# 9. PM2 restart
echo -e "${YELLOW}9️⃣  PM2 uygulaması yeniden başlatılıyor...${NC}"
pm2 restart ${PM2_APP_NAME} --update-env || {
    echo -e "${YELLOW}⚠️  PM2 restart hatası, manuel kontrol gerekebilir${NC}"
}
echo -e "${GREEN}✅ PM2 restart edildi${NC}"
echo ""

# 10. Özet
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    ÖZET                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo -e "${GREEN}✅ Build tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Bilgiler:${NC}"
echo -e "   Yedek dosyası: $BACKUP_FILE"
if [ -f "$DB_PATH" ]; then
    FINAL_BLOG_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
    echo -e "   Blog kayıt sayısı: $FINAL_BLOG_COUNT"
fi
echo ""
echo -e "${YELLOW}📋 Kontrol komutları:${NC}"
echo "   pm2 logs ${PM2_APP_NAME} --lines 20"
echo "   sqlite3 $DB_PATH \"SELECT COUNT(*) FROM BlogPost;\""
echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"

