#!/bin/bash

# Nginx config'deki invalid condition hatalarını düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔧 Nginx invalid condition hatası düzeltiliyor...${NC}"
echo ""

# 1. Yedek al
echo -e "${YELLOW}1️⃣ Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Yedek alındı${NC}"
echo ""

# 2. Satır 108'i kontrol et
echo -e "${YELLOW}2️⃣ Satır 105-115 kontrol ediliyor...${NC}"
sudo sed -n '105,115p' "$NGINX_CONFIG"
echo ""

# 3. Tüm if statement'larını bul
echo -e "${YELLOW}3️⃣ Tüm 'if' statement'ları bulunuyor...${NC}"
sudo grep -n "if" "$NGINX_CONFIG" || echo "   (bulunamadı)"
echo ""

# 4. Config dosyasını düzelt
echo -e "${YELLOW}4️⃣ Config dosyası düzeltiliyor...${NC}"
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

fixed_lines = []
i = 0

while i < len(lines):
    line = lines[i]
    original_line = line
    
    # Hatalı if statement'larını düzelt
    # "if ($host)" -> "if ($host = "")" veya kaldır
    if re.match(r'^\s*if\s+\(\s*\$host\s*\)', line):
        # Bu hatalı, kaldır veya düzelt
        # Genelde bu tür if'ler gereksizdir, kaldıralım
        i += 1
        # Sonraki satırları da kontrol et (if block'unu kapat)
        brace_count = 0
        while i < len(lines):
            if '{' in lines[i]:
                brace_count += lines[i].count('{')
            if '}' in lines[i]:
                brace_count -= lines[i].count('}')
                if brace_count == 0:
                    i += 1
                    break
            i += 1
        continue
    
    # "if $host" -> "if ($host = "")" veya kaldır
    if re.match(r'^\s*if\s+\$host\s*;', line):
        # Hatalı, kaldır
        i += 1
        continue
    
    # Server block dışında kalan SSL direktiflerini kaldır
    if i > 0 and not any('server {' in lines[j] for j in range(max(0, i-20), i)):
        if re.match(r'^\s*ssl_certificate\s+', line):
            # Server block dışında, kaldır
            i += 1
            continue
    
    fixed_lines.append(line)
    i += 1

# Config'i birleştir
content = ''.join(fixed_lines)

# Boş satırları temizle (çok fazla boş satır varsa)
lines = content.split('\n')
cleaned_lines = []
prev_empty = False

for line in lines:
    is_empty = line.strip() == ''
    if is_empty and prev_empty:
        continue
    cleaned_lines.append(line)
    prev_empty = is_empty

content = '\n'.join(cleaned_lines)

# Config dosyasını yaz
with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Config dosyası düzeltildi")
PYEOF

# 5. Nginx test
echo ""
echo -e "${YELLOW}5️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx restart ediliyor...${NC}"
    sudo systemctl restart nginx
    sleep 3
    echo -e "${GREEN}✅ Nginx restart edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}📋 Hata detayları:${NC}"
    sudo nginx -t 2>&1 | head -20
    echo ""
    echo -e "${YELLOW}💡 Satır 105-115:${NC}"
    sudo sed -n '105,115p' "$NGINX_CONFIG"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"

