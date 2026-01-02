#!/bin/bash

# Nginx config'deki duplicate default_server'ları kaldır

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔧 Nginx duplicate default_server kaldırılıyor...${NC}"
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
default_server_found_80 = False
default_server_found_443 = False

while i < len(lines):
    line = lines[i]
    original_line = line
    
    # Duplicate default_server'ları kaldır
    if re.search(r'listen\s+80\s+default_server', line):
        if default_server_found_80:
            # İkinci default_server, kaldır
            line = re.sub(r'\s+default_server', '', line)
        else:
            default_server_found_80 = True
    
    if re.search(r'listen\s+443\s+default_server', line):
        if default_server_found_443:
            # İkinci default_server, kaldır
            line = re.sub(r'\s+default_server', '', line)
        else:
            default_server_found_443 = True
    
    # Gereksiz fotougur.com.tr server block'larını kaldır
    # (Sadece return 404 yapan block'ları kaldır)
    if 'server {' in line:
        # Sonraki birkaç satırı kontrol et
        block_start = i
        brace_count = 1
        j = i + 1
        block_lines = [line]
        
        while j < len(lines) and brace_count > 0:
            block_lines.append(lines[j])
            if '{' in lines[j]:
                brace_count += lines[j].count('{')
            if '}' in lines[j]:
                brace_count -= lines[j].count('}')
            j += 1
        
        block_content = ''.join(block_lines)
        
        # Eğer sadece return 404 yapan bir block ise ve fotougur.com.tr içeriyorsa, kaldır
        if 'fotougur.com.tr' in block_content.lower() and 'return 404' in block_content and 'ssl_certificate' not in block_content:
            # Bu gereksiz block, atla
            i = j
            continue
    
    # server_name satırındaki fazladan boşlukları temizle
    if re.match(r'^\s*server_name\s+', line):
        # Fazladan boşlukları temizle
        line = re.sub(r'\s+', ' ', line)
        # "www." gibi hatalı domain'leri kaldır
        line = re.sub(r'\s+www\.\s*;', ';', line)
        # Fazladan noktalı virgül varsa kaldır
        line = re.sub(r';\s*;', ';', line)
        # "return 404" ile aynı satırda ise ayır
        if 'return 404' in line:
            parts = line.split(';')
            if len(parts) > 1:
                line = parts[0] + ';\n'
                fixed_lines.append(line)
                # return 404'ü ayrı satıra ekle
                if 'return 404' in ';'.join(parts[1:]):
                    fixed_lines.append('    return 404; # managed by Certbot\n')
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

print("✅ Config dosyası düzeltildi (duplicate default_server kaldırıldı)")
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
    echo -e "${YELLOW}💡 Tüm 'default_server' satırları:${NC}"
    sudo grep -n "default_server" "$NGINX_CONFIG" || echo "   (bulunamadı)"
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

