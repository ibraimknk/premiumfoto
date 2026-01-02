#!/bin/bash

# server.js dosyasını tamamen düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

AKTAS_DIR="/var/www/fikirtepetekelpaket.com"
SERVER_JS="$AKTAS_DIR/server.js"

echo -e "${YELLOW}🔧 server.js dosyası tamamen düzeltiliyor...${NC}"

if [ ! -f "$SERVER_JS" ]; then
    echo -e "${RED}❌ server.js bulunamadı: $SERVER_JS${NC}"
    exit 1
fi

# Yedek al
BACKUP_FILE="$SERVER_JS.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SERVER_JS" "$BACKUP_FILE"
echo -e "${GREEN}✅ Yedek alındı: $BACKUP_FILE${NC}"

# İlk satırı oku
FIRST_LINE=$(head -1 "$SERVER_JS")
echo -e "${YELLOW}📝 İlk satır: $FIRST_LINE${NC}"

# Eğer bozuksa düzelt
if echo "$FIRST_LINE" | grep -q "process.env.PORT || 3001import"; then
    echo -e "${YELLOW}⚠️  Bozuk satır bulundu, düzeltiliyor...${NC}"
    
    # Tüm dosyayı oku
    FULL_CONTENT=$(cat "$SERVER_JS")
    
    # Bozuk satırı düzelt: process.env.PORT || 3001import -> import
    FIXED_CONTENT=$(echo "$FULL_CONTENT" | sed 's/^process\.env\.PORT || 3001import/import/')
    
    # Eğer hala sorun varsa, tüm process.env.PORT || 3001 ile başlayan satırları düzelt
    FIXED_CONTENT=$(echo "$FIXED_CONTENT" | sed 's/^process\.env\.PORT || 3001\([^|]\)/\1/')
    
    # Dosyayı yaz
    echo "$FIXED_CONTENT" > "$SERVER_JS"
    echo -e "${GREEN}✅ Dosya düzeltildi${NC}"
    
    # Kontrol et
    if node -c "$SERVER_JS" 2>/dev/null; then
        echo -e "${GREEN}✅ Syntax kontrolü başarılı${NC}"
    else
        echo -e "${RED}❌ Syntax kontrolü başarısız, yedekten geri yükleniyor...${NC}"
        cp "$BACKUP_FILE" "$SERVER_JS"
        
        # Manuel düzeltme: Python ile
        echo -e "${YELLOW}🔧 Python ile düzeltme deneniyor...${NC}"
        python3 << PYEOF
import re

with open("$SERVER_JS", 'r', encoding='utf-8') as f:
    content = f.read()

# İlk satırı düzelt
lines = content.split('\n')
if lines and 'process.env.PORT || 3001import' in lines[0]:
    # process.env.PORT || 3001import express -> import express
    lines[0] = re.sub(r'^process\.env\.PORT \|\| 3001', '', lines[0])
    # Eğer hala sorun varsa
    if lines[0].startswith('import'):
        pass  # Zaten düzeltilmiş
    elif 'import' in lines[0]:
        # import'u başa al
        import_match = re.search(r'import\s+.*', lines[0])
        if import_match:
            lines[0] = import_match.group(0)

# Tüm satırlarda process.env.PORT || 3001 ile başlayanları temizle
fixed_lines = []
for line in lines:
    if line.strip().startswith('process.env.PORT || 3001') and 'import' in line:
        # process.env.PORT || 3001 kısmını kaldır
        line = re.sub(r'^process\.env\.PORT \|\| 3001', '', line)
    fixed_lines.append(line)

content = '\n'.join(fixed_lines)

with open("$SERVER_JS", 'w', encoding='utf-8') as f:
    f.write(content)

print("Dosya düzeltildi")
PYEOF
        
        # Tekrar kontrol
        if node -c "$SERVER_JS" 2>/dev/null; then
            echo -e "${GREEN}✅ Python düzeltmesi başarılı${NC}"
        else
            echo -e "${RED}❌ Hala syntax hatası var, yedekten geri yükleniyor...${NC}"
            cp "$BACKUP_FILE" "$SERVER_JS"
            
            # Son çare: İlk satırı manuel düzelt
            echo -e "${YELLOW}🔧 Manuel düzeltme yapılıyor...${NC}"
            # İlk satırı oku ve düzelt
            FIRST_LINE_FIXED=$(head -1 "$SERVER_JS" | sed 's/^process\.env\.PORT || 3001//' | sed 's/^process\.env\.PORT || 3001|| 3001//')
            
            # Eğer import ile başlamıyorsa, import'u bul
            if ! echo "$FIRST_LINE_FIXED" | grep -q "^import"; then
                IMPORT_PART=$(echo "$FIRST_LINE_FIXED" | grep -o "import.*" || echo "")
                if [ ! -z "$IMPORT_PART" ]; then
                    FIRST_LINE_FIXED="$IMPORT_PART"
                fi
            fi
            
            # Dosyanın geri kalanını al
            TAIL_CONTENT=$(tail -n +2 "$SERVER_JS")
            
            # Düzeltilmiş içeriği yaz
            echo "$FIRST_LINE_FIXED" > "$SERVER_JS"
            echo "$TAIL_CONTENT" >> "$SERVER_JS"
            
            echo -e "${GREEN}✅ Manuel düzeltme tamamlandı${NC}"
        fi
    fi
else
    echo -e "${GREEN}✅ Dosya zaten düzgün görünüyor${NC}"
fi

# Son kontrol
echo -e "${YELLOW}📝 İlk 5 satır:${NC}"
head -5 "$SERVER_JS"

# Syntax kontrolü
if node -c "$SERVER_JS" 2>/dev/null; then
    echo -e "${GREEN}✅ Syntax kontrolü başarılı!${NC}"
else
    echo -e "${RED}❌ Syntax hatası devam ediyor!${NC}"
    echo -e "${YELLOW}💡 Yedek dosya: $BACKUP_FILE${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ server.js düzeltildi!${NC}"

