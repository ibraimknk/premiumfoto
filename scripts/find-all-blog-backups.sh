#!/bin/bash

# Tüm blog yedeklerini bul

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Tüm blog yedekleri aranıyor...${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 1. Mevcut veritabanı kontrolü
DB_PATH="$HOME/premiumfoto/prisma/dev.db"
echo -e "${YELLOW}1️⃣ Mevcut veritabanı:${NC}"
if [ -f "$DB_PATH" ]; then
    DB_SIZE=$(du -h "$DB_PATH" | cut -f1)
    BLOG_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
    echo -e "${GREEN}✅ Veritabanı mevcut: $DB_PATH${NC}"
    echo -e "${YELLOW}   Boyut: $DB_SIZE${NC}"
    echo -e "${YELLOW}   Blog sayısı: $BLOG_COUNT${NC}"
    
    if [ "$BLOG_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}   Mevcut bloglar:${NC}"
        sqlite3 "$DB_PATH" "SELECT id, title, createdAt FROM BlogPost ORDER BY createdAt DESC LIMIT 10;" 2>/dev/null | while IFS='|' read -r id title created; do
            echo -e "${YELLOW}     - ID: $id | $title | $created${NC}"
        done
    fi
else
    echo -e "${RED}❌ Veritabanı bulunamadı${NC}"
fi
echo ""

# 2. Tüm .db dosyalarını bul
echo -e "${YELLOW}2️⃣ Sistem genelinde .db dosyaları aranıyor...${NC}"
DB_FILES=$(find ~ -name "*.db" -type f 2>/dev/null | grep -v node_modules | grep -v ".next")
if [ ! -z "$DB_FILES" ]; then
    echo -e "${GREEN}✅ .db dosyaları bulundu:${NC}"
    echo "$DB_FILES" | while read db_file; do
        if [ -f "$db_file" ]; then
            DB_SIZE=$(du -h "$db_file" | cut -f1)
            DB_DATE=$(stat -c %y "$db_file" 2>/dev/null || stat -f "%Sm" "$db_file" 2>/dev/null || echo "bilinmiyor")
            
            # Blog sayısını kontrol et
            BLOG_COUNT=$(sqlite3 "$db_file" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
            
            echo -e "${YELLOW}   📁 $db_file${NC}"
            echo -e "${YELLOW}      Boyut: $DB_SIZE | Tarih: $DB_DATE | Blog sayısı: $BLOG_COUNT${NC}"
            
            if [ "$BLOG_COUNT" -gt 0 ]; then
                echo -e "${GREEN}      ✅ Bu dosyada bloglar var!${NC}"
                sqlite3 "$db_file" "SELECT id, title, createdAt FROM BlogPost ORDER BY createdAt DESC LIMIT 5;" 2>/dev/null | while IFS='|' read -r id title created; do
                    echo -e "${YELLOW}         - $title ($created)${NC}"
                done
            fi
            echo ""
        fi
    done
else
    echo -e "${RED}❌ .db dosyası bulunamadı${NC}"
fi

# 3. Backup dizinlerini kontrol et
echo -e "${YELLOW}3️⃣ Backup dizinleri kontrol ediliyor...${NC}"
BACKUP_DIRS=(
    "$HOME/premiumfoto/backups"
    "$HOME/backup"
    "$HOME/premiumfoto/prisma"
    "/var/backups"
)

for backup_dir in "${BACKUP_DIRS[@]}"; do
    if [ -d "$backup_dir" ]; then
        echo -e "${YELLOW}📁 $backup_dir:${NC}"
        find "$backup_dir" -name "*.db" -o -name "*.sqlite" -o -name "*.sql" -o -name "*backup*" 2>/dev/null | while read backup_file; do
            if [ -f "$backup_file" ]; then
                BACKUP_SIZE=$(du -h "$backup_file" | cut -f1)
                BACKUP_DATE=$(stat -c %y "$backup_file" 2>/dev/null || stat -f "%Sm" "$backup_file" 2>/dev/null || echo "bilinmiyor")
                
                # Eğer .db dosyasıysa blog sayısını kontrol et
                if [[ "$backup_file" == *.db ]]; then
                    BLOG_COUNT=$(sqlite3 "$backup_file" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
                    echo -e "${YELLOW}     📄 $(basename $backup_file) ($BACKUP_SIZE, $BACKUP_DATE) - Blog: $BLOG_COUNT${NC}"
                    
                    if [ "$BLOG_COUNT" -gt 0 ]; then
                        echo -e "${GREEN}       ✅ Bu yedekte bloglar var!${NC}"
                    fi
                else
                    echo -e "${YELLOW}     📄 $(basename $backup_file) ($BACKUP_SIZE, $BACKUP_DATE)${NC}"
                fi
            fi
        done
    fi
done

# 4. Git geçmişini kontrol et (eğer veritabanı commit edilmişse)
echo ""
echo -e "${YELLOW}4️⃣ Git geçmişi kontrol ediliyor...${NC}"
cd "$HOME/premiumfoto"
if git log --all --full-history -- "*dev.db" -- "*prisma/dev.db" 2>/dev/null | head -5; then
    echo -e "${GREEN}✅ Git geçmişinde veritabanı dosyaları bulundu${NC}"
    echo -e "${YELLOW}💡 Eski commit'lerden veritabanını geri yükleyebilirsiniz:${NC}"
    echo "   git log --all --full-history -- '*dev.db'"
else
    echo -e "${YELLOW}⚠️  Git geçmişinde veritabanı dosyası bulunamadı (normal, .gitignore'da olabilir)${NC}"
fi

echo ""
echo -e "${BLUE}📊 Özet:${NC}"
echo -e "${BLUE}================================${NC}"

# En çok blog içeren dosyayı bul
MOST_BLOGS=0
BEST_BACKUP=""

echo "$DB_FILES" | while read db_file; do
    if [ -f "$db_file" ]; then
        BLOG_COUNT=$(sqlite3 "$db_file" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
        if [ "$BLOG_COUNT" -gt "$MOST_BLOGS" ]; then
            MOST_BLOGS=$BLOG_COUNT
            BEST_BACKUP="$db_file"
        fi
    fi
done

if [ ! -z "$BEST_BACKUP" ] && [ "$MOST_BLOGS" -gt 0 ]; then
    echo -e "${GREEN}✅ En çok blog içeren yedek: $BEST_BACKUP ($MOST_BLOGS blog)${NC}"
    echo -e "${YELLOW}💡 Bu yedeği geri yüklemek için:${NC}"
    echo "   bash scripts/restore-database-backup.sh"
else
    echo -e "${RED}❌ Blog içeren yedek bulunamadı${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Yedek oluşturma komutu:${NC}"
echo "   sqlite3 $DB_PATH \".backup '$HOME/premiumfoto/backups/dev.db.backup.\$(date +%Y%m%d_%H%M%S)'\""

