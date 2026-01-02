#!/bin/bash

# Daha derin blog yedek arama (git geçmişi, tüm backup dizinleri)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Derin blog yedek araması başlatılıyor...${NC}"
echo ""

APP_DIR="$HOME/premiumfoto"
cd "$APP_DIR"

# 1. Git geçmişindeki tüm commit'leri kontrol et
echo -e "${YELLOW}1️⃣ Git geçmişi detaylı kontrol ediliyor...${NC}"
GIT_COMMITS=$(git log --all --oneline --name-only | grep -E "(dev\.db|prisma)" | head -20)

if [ ! -z "$GIT_COMMITS" ]; then
    echo -e "${GREEN}✅ Git geçmişinde veritabanı referansları bulundu${NC}"
    echo "$GIT_COMMITS"
else
    echo -e "${YELLOW}⚠️  Git geçmişinde veritabanı referansı bulunamadı${NC}"
fi

# 2. Tüm backup dosyalarını bul (daha geniş arama)
echo ""
echo -e "${YELLOW}2️⃣ Tüm sistemde backup dosyaları aranıyor...${NC}"
BACKUP_PATTERNS=(
    "*backup*.db"
    "*dev.db*"
    "*.sqlite"
    "*.sqlite3"
    "*prisma*.db"
)

for pattern in "${BACKUP_PATTERNS[@]}"; do
    echo -e "${YELLOW}   Aranıyor: $pattern${NC}"
    find ~ -name "$pattern" -type f 2>/dev/null | grep -v node_modules | grep -v ".next" | grep -v ".cache" | while read backup_file; do
        if [ -f "$backup_file" ]; then
            BACKUP_SIZE=$(du -h "$backup_file" | cut -f1)
            BACKUP_DATE=$(stat -c %y "$backup_file" 2>/dev/null || echo "bilinmiyor")
            
            # Blog sayısını kontrol et
            BLOG_COUNT=$(sqlite3 "$backup_file" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
            
            if [ "$BLOG_COUNT" -gt 0 ]; then
                echo -e "${GREEN}      ✅ $backup_file ($BACKUP_SIZE, $BACKUP_DATE) - Blog: $BLOG_COUNT${NC}"
                sqlite3 "$backup_file" "SELECT id, title, createdAt FROM BlogPost ORDER BY createdAt DESC LIMIT 3;" 2>/dev/null | while IFS='|' read -r id title created; do
                    echo -e "${YELLOW}         - $title ($created)${NC}"
                done
            fi
        fi
    done
done

# 3. /var/backups ve /tmp dizinlerini kontrol et
echo ""
echo -e "${YELLOW}3️⃣ Sistem backup dizinleri kontrol ediliyor...${NC}"
SYSTEM_BACKUP_DIRS=(
    "/var/backups"
    "/tmp"
    "/root/backups"
    "/home/ibrahim/backups"
    "/home/ibrahim/premiumfoto/backups"
)

for backup_dir in "${SYSTEM_BACKUP_DIRS[@]}"; do
    if [ -d "$backup_dir" ]; then
        echo -e "${YELLOW}📁 $backup_dir:${NC}"
        find "$backup_dir" -type f \( -name "*.db" -o -name "*.sqlite" -o -name "*.sql" \) 2>/dev/null | while read backup_file; do
            if [ -f "$backup_file" ]; then
                BACKUP_SIZE=$(du -h "$backup_file" | cut -f1)
                BACKUP_DATE=$(stat -c %y "$backup_file" 2>/dev/null || echo "bilinmiyor")
                
                if [[ "$backup_file" == *.db ]] || [[ "$backup_file" == *.sqlite ]]; then
                    BLOG_COUNT=$(sqlite3 "$backup_file" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
                    echo -e "${YELLOW}     📄 $(basename $backup_file) ($BACKUP_SIZE, $BACKUP_DATE) - Blog: $BLOG_COUNT${NC}"
                    
                    if [ "$BLOG_COUNT" -gt 0 ]; then
                        echo -e "${GREEN}       ✅ Bu yedekte bloglar var!${NC}"
                    fi
                fi
            fi
        done
    fi
done

# 4. PM2 dump dosyalarını kontrol et (eğer varsa)
echo ""
echo -e "${YELLOW}4️⃣ PM2 dump dosyaları kontrol ediliyor...${NC}"
PM2_DUMP="$HOME/.pm2/dump.pm2"
if [ -f "$PM2_DUMP" ]; then
    echo -e "${YELLOW}📄 PM2 dump bulundu: $PM2_DUMP${NC}"
    # PM2 dump'ta veritabanı path'leri olabilir
    grep -i "dev.db\|prisma" "$PM2_DUMP" 2>/dev/null || echo "   Veritabanı referansı bulunamadı"
fi

# 5. Son değiştirilen .db dosyalarını listele
echo ""
echo -e "${YELLOW}5️⃣ Son değiştirilen .db dosyaları (son 30 gün)...${NC}"
find ~/premiumfoto -name "*.db" -type f -mtime -30 2>/dev/null | while read db_file; do
    if [ -f "$db_file" ]; then
        DB_SIZE=$(du -h "$db_file" | cut -f1)
        DB_DATE=$(stat -c %y "$db_file" 2>/dev/null || echo "bilinmiyor")
        BLOG_COUNT=$(sqlite3 "$db_file" "SELECT COUNT(*) FROM BlogPost;" 2>/dev/null || echo "0")
        
        echo -e "${YELLOW}   📁 $db_file${NC}"
        echo -e "${YELLOW}      Boyut: $DB_SIZE | Tarih: $DB_DATE | Blog: $BLOG_COUNT${NC}"
        
        if [ "$BLOG_COUNT" -gt 5 ]; then
            echo -e "${GREEN}      ✅ Bu dosyada daha fazla blog var! ($BLOG_COUNT)${NC}"
        fi
    fi
done

# 6. Özet
echo ""
echo -e "${BLUE}📊 Özet:${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}💡 Eğer yedek bulunamadıysa:${NC}"
echo "   1. Veritabanı manuel olarak silinmiş olabilir"
echo "   2. Yedek alınmamış olabilir"
echo "   3. Yedek farklı bir sunucuda olabilir"
echo ""
echo -e "${YELLOW}💡 Öneriler:${NC}"
echo "   - Düzenli yedek almak için cron job kurun"
echo "   - Git'e veritabanı commit etmeyin (çok büyük olur)"
echo "   - Yedekleri ayrı bir dizinde saklayın"

