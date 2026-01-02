#!/bin/bash

# Nginx config'deki syntax hatalarını düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔧 Nginx syntax hataları düzeltiliyor...${NC}"
echo ""

# 1. Yedek al
echo -e "${YELLOW}1️⃣ Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Yedek alındı${NC}"
echo ""

# 2. Satır 105-120'yi kontrol et
echo -e "${YELLOW}2️⃣ Satır 105-120 kontrol ediliyor...${NC}"
sudo sed -n '105,120p' "$NGINX_CONFIG"
echo ""

# 3. Config dosyasını düzelt
echo -e "${YELLOW}3️⃣ Config dosyası düzeltiliyor...${NC}"
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
    
    # "listen 80; default_server;" -> "listen 80 default_server;"
    if re.match(r'^\s*listen\s+80\s*;\s*default_server\s*;', line):
        line = re.sub(r'listen\s+80\s*;\s*default_server\s*;', 'listen 80 default_server;', line)
    elif re.match(r'^\s*listen\s+80\s*;', line) and i + 1 < len(lines) and 'default_server' in lines[i + 1]:
        # listen 80; ve sonraki satırda default_server varsa birleştir
        line = re.sub(r'listen\s+80\s*;', 'listen 80 default_server;', line)
        i += 1  # Sonraki satırı atla
        fixed_lines.append(line)
        continue
    
    # "listen 443; ssl;" -> "listen 443 ssl;"
    if re.match(r'^\s*listen\s+443\s*;\s*ssl\s*;', line):
        line = re.sub(r'listen\s+443\s*;\s*ssl\s*;', 'listen 443 ssl;', line)
    elif re.match(r'^\s*listen\s+443\s*;', line) and i + 1 < len(lines) and 'ssl' in lines[i + 1] and 'ssl_certificate' not in lines[i + 1]:
        line = re.sub(r'listen\s+443\s*;', 'listen 443 ssl;', line)
        i += 1  # Sonraki satırı atla
        fixed_lines.append(line)
        continue
    
    # server_name satırındaki fazladan boşlukları ve hatalı domain'leri temizle
    if re.match(r'^\s*server_name\s+', line):
        # Fazladan boşlukları temizle
        line = re.sub(r'\s+', ' ', line)
        # "www." gibi hatalı domain'leri kaldır
        line = re.sub(r'\s+www\.\s*;', ';', line)
        # Fazladan noktalı virgül varsa kaldır
        line = re.sub(r';\s*;', ';', line)
    
    # Boş if condition'larını kaldır
    if re.match(r'^\s*if\s+\(\s*\$host\s*=\s*\)\s*\{', line):
        # Boş if condition, tüm block'u atla
        brace_count = 1
        i += 1
        while i < len(lines) and brace_count > 0:
            if '{' in lines[i]:
                brace_count += lines[i].count('{')
            if '}' in lines[i]:
                brace_count -= lines[i].count('}')
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

print("✅ Config dosyası düzeltildi (syntax hataları düzeltildi)")
PYEOF

# 4. Nginx test
echo ""
echo -e "${YELLOW}4️⃣ Nginx test ediliyor...${NC}"
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
    echo -e "${YELLOW}💡 Satır 105-120:${NC}"
    sudo sed -n '105,120p' "$NGINX_CONFIG"
    echo ""
    echo -e "${YELLOW}💡 Tüm 'listen' satırları:${NC}"
    sudo grep -n "listen" "$NGINX_CONFIG" | head -20
    exit 1
fi

# 5. Test
echo ""
echo -e "${YELLOW}5️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr" "fotougur.com.tr")
for domain in "${DOMAINS[@]}"; do
    echo -e "${YELLOW}   Test ediliyor: https://${domain}${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 -k https://${domain} 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}   ✅ ${domain}: HTTPS ${HTTP_CODE}${NC}"
    else
        echo -e "${RED}   ❌ ${domain}: HTTPS ${HTTP_CODE}${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"

