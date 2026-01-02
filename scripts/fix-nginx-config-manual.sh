#!/bin/bash

# Nginx config'i manuel düzelt - satır 41 hatası

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔧 Nginx config manuel düzeltiliyor...${NC}"
echo ""

# 1. Git conflict çöz
echo -e "${YELLOW}1️⃣ Git conflict çözülüyor...${NC}"
cd ~/premiumfoto
git stash
git pull origin main
echo -e "${GREEN}✅ Git conflict çözüldü${NC}"
echo ""

# 2. Config dosyasının 41. satırını kontrol et
echo -e "${YELLOW}2️⃣ Config dosyasının 41. satırı kontrol ediliyor...${NC}"
sudo sed -n '35,45p' "$NGINX_CONFIG"
echo ""

# 3. Config dosyasını düzelt
echo -e "${YELLOW}3️⃣ Config dosyası düzeltiliyor...${NC}"
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = 3040
cert_path = "/etc/letsencrypt/live/fotougur.com.tr"

with open(config_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Satır 41'i kontrol et ve düzelt
if len(lines) > 40:
    line_41 = lines[40]  # 0-indexed, so line 41 is index 40
    print(f"Satır 41: {line_41.strip()}")
    
    # Eğer proxy_set_header satırında sorun varsa düzelt
    if 'proxy_set_header' in line_41 and line_41.count('$') % 2 != 0:
        print("Satır 41'de $ karakteri sorunu bulundu, düzeltiliyor...")
        lines[40] = line_41.replace('$', '$$')

# Tüm dosyayı kontrol et - proxy_set_header satırlarında $ karakterlerini düzelt
fixed_lines = []
for i, line in enumerate(lines):
    if 'proxy_set_header' in line:
        # $ karakterlerini say
        dollar_count = line.count('$')
        if dollar_count > 0 and dollar_count % 2 == 0:
            # Çift sayıda $ var, tek sayıya çevir (her $'ı $$ yap)
            line = line.replace('$', '$$')
        elif dollar_count == 1:
            # Tek $ var, $$ yap
            line = line.replace('$', '$$')
        fixed_lines.append(line)
    else:
        fixed_lines.append(line)

# Dosyayı yaz
with open(config_file, 'w', encoding='utf-8') as f:
    f.writelines(fixed_lines)

print("Config düzeltildi")
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
    sudo nginx -t 2>&1 | head -10
    exit 1
fi

# 5. Test
echo ""
echo -e "${YELLOW}5️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr")
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

