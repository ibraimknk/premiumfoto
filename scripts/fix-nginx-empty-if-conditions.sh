#!/bin/bash

# Nginx config'deki boş if condition'larını kaldır

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔧 Nginx boş if condition'ları kaldırılıyor...${NC}"
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
skip_if_block = False
if_brace_count = 0

while i < len(lines):
    line = lines[i]
    original_line = line
    
    # Boş if condition'larını tespit et
    if re.match(r'^\s*if\s+\(\s*\$host\s*=\s*\)\s*\{', line):
        # Boş if condition, tüm block'u atla
        skip_if_block = True
        if_brace_count = 1
        i += 1
        continue
    
    if skip_if_block:
        if '{' in line:
            if_brace_count += line.count('{')
        if '}' in line:
            if_brace_count -= line.count('}')
            if if_brace_count == 0:
                skip_if_block = False
                # Son } satırını da atla
                i += 1
                continue
        i += 1
        continue
    
    # Server block dışında kalan SSL direktiflerini kaldır
    # (Eğer önceki 20 satırda server { yoksa)
    if i > 0:
        prev_lines = ''.join(lines[max(0, i-20):i])
        if not re.search(r'server\s*\{', prev_lines, re.DOTALL):
            if re.match(r'^\s*ssl_certificate\s+', line):
                i += 1
                continue
            if re.match(r'^\s*ssl_certificate_key\s+', line):
                i += 1
                continue
            if re.match(r'^\s*include\s+/etc/letsencrypt/options-ssl-nginx.conf', line):
                i += 1
                continue
            if re.match(r'^\s*ssl_dhparam\s+', line):
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

print("✅ Config dosyası düzeltildi (boş if condition'ları kaldırıldı)")
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
    echo -e "${YELLOW}💡 Tüm 'if' statement'ları:${NC}"
    sudo grep -n "if" "$NGINX_CONFIG" || echo "   (bulunamadı)"
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

