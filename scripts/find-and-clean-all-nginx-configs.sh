#!/bin/bash

# Tüm Nginx config dosyalarını bul ve temizle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Tüm Nginx config dosyaları bulunuyor...${NC}"
echo ""

# 1. Tüm nginx config dosyalarını bul
echo -e "${YELLOW}1️⃣ Nginx config dosyaları aranıyor...${NC}"
NGINX_CONFIGS=$(sudo find /etc/nginx -name "*.conf" -o -name "*" -type f 2>/dev/null | grep -E "(sites-available|sites-enabled|conf.d)" | sort -u)

echo -e "${GREEN}✅ Bulunan config dosyaları:${NC}"
for config in $NGINX_CONFIGS; do
    if [ -f "$config" ]; then
        echo "   - $config"
    fi
done
echo ""

# 2. sites-enabled ve sites-available dosyalarını listele
echo -e "${YELLOW}2️⃣ sites-available ve sites-enabled dosyaları:${NC}"
echo -e "${BLUE}sites-available:${NC}"
sudo ls -la /etc/nginx/sites-available/ 2>/dev/null | grep -v "^total" || echo "   (boş)"
echo ""
echo -e "${BLUE}sites-enabled:${NC}"
sudo ls -la /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "^total" || echo "   (boş)"
echo ""

# 3. Ana config dosyasını kontrol et
MAIN_CONFIG="/etc/nginx/sites-available/foto-ugur"
echo -e "${YELLOW}3️⃣ Ana config dosyası kontrol ediliyor: ${MAIN_CONFIG}${NC}"
if [ -f "$MAIN_CONFIG" ]; then
    echo -e "${GREEN}✅ Dosya mevcut${NC}"
    echo -e "${YELLOW}   Satır sayısı: $(sudo wc -l < "$MAIN_CONFIG")${NC}"
    echo -e "${YELLOW}   Satır 105-115:${NC}"
    sudo sed -n '105,115p' "$MAIN_CONFIG"
    echo ""
else
    echo -e "${RED}❌ Dosya bulunamadı${NC}"
fi

# 4. Hatalı satırları bul
echo -e "${YELLOW}4️⃣ Hatalı satırlar aranıyor...${NC}"
if [ -f "$MAIN_CONFIG" ]; then
    # invalid condition hatası genelde if statement'larında olur
    echo -e "${BLUE}   'if' statement'ları:${NC}"
    sudo grep -n "if" "$MAIN_CONFIG" | head -10 || echo "   (bulunamadı)"
    echo ""
    echo -e "${BLUE}   Satır 108 civarı:${NC}"
    sudo sed -n '103,113p' "$MAIN_CONFIG"
    echo ""
fi

# 5. Config dosyasını düzelt
echo -e "${YELLOW}5️⃣ Config dosyası düzeltiliyor...${NC}"
sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

try:
    with open(config_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Hatalı if statement'larını bul ve düzelt
    # "if ($host" gibi hatalı kullanımları düzelt
    # Nginx'te if condition'ları genelde "if ($variable)" şeklinde olmalı
    
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Hatalı if statement'larını tespit et
        if re.match(r'^\s*if\s+\(\s*\$host\s*\)', line):
            # Bu hatalı, düzelt
            fixed_lines.append(line.replace('if ($host)', 'if ($host = "")'))
        elif re.match(r'^\s*if\s+\$host', line):
            # Parantez eksik, ekle
            fixed_lines.append(re.sub(r'if\s+(\$host)', r'if (\1)', line))
        else:
            fixed_lines.append(line)
    
    # Eğer değişiklik yapıldıysa kaydet
    new_content = '\n'.join(fixed_lines)
    if new_content != content:
        with open(config_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("✅ Config dosyası düzeltildi")
    else:
        print("ℹ️  Config dosyasında hata bulunamadı, manuel kontrol gerekebilir")
        
except Exception as e:
    print(f"❌ Hata: {e}")
PYEOF

# 6. Nginx test
echo ""
echo -e "${YELLOW}6️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t 2>&1 | tee /tmp/nginx-test.log; then
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
    sudo sed -n '105,115p' "$MAIN_CONFIG"
    echo ""
    echo -e "${YELLOW}💡 Tüm 'if' statement'ları:${NC}"
    sudo grep -n "if" "$MAIN_CONFIG" || echo "   (bulunamadı)"
fi

echo ""
echo -e "${GREEN}✅ İşlem tamamlandı!${NC}"

