#!/bin/bash

# Git conflict çöz ve Nginx config'i düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔧 Git conflict çözülüyor ve Nginx config düzeltiliyor...${NC}"
echo ""

# 1. Git conflict çöz
echo -e "${YELLOW}1️⃣ Git conflict çözülüyor...${NC}"
cd ~/premiumfoto
git stash
git pull origin main
echo -e "${GREEN}✅ Git conflict çözüldü${NC}"
echo ""

# 2. Config dosyasının 41. satırını kontrol et
echo -e "${YELLOW}2️⃣ Config dosyasının 35-45 satırları kontrol ediliyor...${NC}"
sudo sed -n '35,45p' "$NGINX_CONFIG" || true
echo ""

# 3. Config dosyasını düzelt - proxy_set_header satırlarındaki $ karakterlerini düzelt
echo -e "${YELLOW}3️⃣ Config dosyası düzeltiliyor...${NC}"
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Tüm proxy_set_header satırlarını bul ve düzelt
lines = content.split('\n')
fixed_lines = []

for i, line in enumerate(lines):
    if 'proxy_set_header' in line:
        # $ karakterlerini kontrol et
        # Eğer tek sayıda $ varsa veya $ karakteri yanlış kullanılmışsa düzelt
        # Nginx'te $ karakteri değişken için kullanılır, Python f-string'inde $$ olmalı
        # Ama dosyaya yazarken tek $ olmalı
        
        # Eğer $$ varsa tek $'a çevir (Python f-string escape'i geri al)
        if '$$' in line:
            line = line.replace('$$', '$')
        fixed_lines.append(line)
    else:
        fixed_lines.append(line)

# Dosyayı yaz
with open(config_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(fixed_lines))

print("Config düzeltildi - proxy_set_header satırları kontrol edildi")
PYEOF

# 4. Nginx test
echo ""
echo -e "${YELLOW}4️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t 2>&1 | tee /tmp/nginx-test.log; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx restart ediliyor...${NC}"
    sudo systemctl restart nginx
    sleep 3
    echo -e "${GREEN}✅ Nginx restart edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}📋 Hata detayları:${NC}"
    cat /tmp/nginx-test.log | grep -A 5 "error\|emerg" | head -10
    echo ""
    echo -e "${YELLOW}💡 Manuel düzeltme gerekebilir:${NC}"
    echo "   sudo nano $NGINX_CONFIG"
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

