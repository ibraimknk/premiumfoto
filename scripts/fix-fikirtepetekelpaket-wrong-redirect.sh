#!/bin/bash

# fikirtepetekelpaket.com'un foto-ugur'a yönlenmesini düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
FIKIRTEPE_CONFIG="/etc/nginx/sites-available/fikirtepetekelpaket.com"
FIKIRTEPE_ENABLED="/etc/nginx/sites-enabled/fikirtepetekelpaket.com"

echo -e "${BLUE}🔧 fikirtepetekelpaket.com yönlendirme sorunu düzeltiliyor...${NC}"
echo ""

# 1. foto-ugur config'inde fikirtepetekelpaket.com var mı kontrol et
echo -e "${YELLOW}1️⃣ foto-ugur config'inde fikirtepetekelpaket.com kontrol ediliyor...${NC}"
if [ -f "$FOTO_UGUR_CONFIG" ]; then
    if sudo grep -q "fikirtepetekelpaket.com" "$FOTO_UGUR_CONFIG"; then
        echo -e "${RED}❌ foto-ugur config'inde fikirtepetekelpaket.com bulundu!${NC}"
        echo -e "${YELLOW}📋 Bulunan satırlar:${NC}"
        sudo grep -n "fikirtepetekelpaket.com" "$FOTO_UGUR_CONFIG" || true
        echo ""
        
        # Yedek al
        sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✅ Yedek alındı${NC}"
        
        # fikirtepetekelpaket.com'u temizle
        echo -e "${YELLOW}🧹 fikirtepetekelpaket.com temizleniyor...${NC}"
        sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# fikirtepetekelpaket.com içeren server block'larını kaldır
lines = content.split('\n')
fixed_lines = []
i = 0
in_fikirtepe_block = False
brace_count = 0

while i < len(lines):
    line = lines[i]
    
    if 'server {' in line:
        # Sonraki birkaç satırı kontrol et
        block_start = i
        brace_count = 1
        block_lines = [line]
        j = i + 1
        
        while j < len(lines) and brace_count > 0:
            block_lines.append(lines[j])
            if '{' in lines[j]:
                brace_count += lines[j].count('{')
            if '}' in lines[j]:
                brace_count -= lines[j].count('}')
            j += 1
        
        block_content = ''.join(block_lines)
        
        # Eğer fikirtepetekelpaket.com içeriyorsa ve dugunkarem/fotougur içermiyorsa, atla
        if 'fikirtepetekelpaket.com' in block_content.lower() and 'dugunkarem' not in block_content.lower() and 'fotougur' not in block_content.lower():
            # Bu block'u atla
            i = j
            continue
    
    # server_name satırından fikirtepetekelpaket.com'u kaldır
    if 'server_name' in line and 'fikirtepetekelpaket.com' in line:
        # fikirtepetekelpaket.com'u kaldır
        line = re.sub(r'\s+fikirtepetekelpaket\.com', '', line, flags=re.IGNORECASE)
        line = re.sub(r'\s+www\.fikirtepetekelpaket\.com', '', line, flags=re.IGNORECASE)
        # Fazladan boşlukları temizle
        line = re.sub(r'\s+', ' ', line)
    
    fixed_lines.append(line)
    i += 1

content = '\n'.join(fixed_lines)

# Boş satırları temizle
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

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ foto-ugur config'inden fikirtepetekelpaket.com temizlendi")
PYEOF
        echo -e "${GREEN}✅ Temizlendi${NC}"
    else
        echo -e "${GREEN}✅ foto-ugur config'inde fikirtepetekelpaket.com yok${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  foto-ugur config bulunamadı${NC}"
fi
echo ""

# 2. fikirtepetekelpaket.com config'i kontrol et
echo -e "${YELLOW}2️⃣ fikirtepetekelpaket.com config'i kontrol ediliyor...${NC}"
if [ -f "$FIKIRTEPE_CONFIG" ]; then
    echo -e "${GREEN}✅ Config dosyası mevcut: $FIKIRTEPE_CONFIG${NC}"
    
    # Config içeriğini kontrol et
    if sudo grep -q "proxy_pass.*3001" "$FIKIRTEPE_CONFIG"; then
        echo -e "${GREEN}✅ proxy_pass port 3001'e ayarlı${NC}"
    else
        echo -e "${RED}❌ proxy_pass port 3001'e ayarlı değil!${NC}"
        echo -e "${YELLOW}📋 Mevcut proxy_pass:${NC}"
        sudo grep "proxy_pass" "$FIKIRTEPE_CONFIG" || echo "   (bulunamadı)"
    fi
    
    # Config aktif mi kontrol et
    if [ -L "$FIKIRTEPE_ENABLED" ]; then
        echo -e "${GREEN}✅ Config aktif (sites-enabled'da link var)${NC}"
    else
        echo -e "${YELLOW}⚠️  Config aktif değil, aktif ediliyor...${NC}"
        sudo ln -sf "$FIKIRTEPE_CONFIG" "$FIKIRTEPE_ENABLED"
        echo -e "${GREEN}✅ Config aktif edildi${NC}"
    fi
else
    echo -e "${RED}❌ fikirtepetekelpaket.com config dosyası bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Önce config oluşturun:${NC}"
    echo "   sudo bash scripts/setup-fikirtepetekelpaket-safe.sh"
    exit 1
fi
echo ""

# 3. Nginx test
echo -e "${YELLOW}3️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
    sudo systemctl reload nginx
    sleep 2
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}📋 Hata detayları:${NC}"
    sudo nginx -t 2>&1 | head -20
    exit 1
fi
echo ""

# 4. Test
echo -e "${YELLOW}4️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr" "fotougur.com.tr" "fikirtepetekelpaket.com")
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
echo -e "${YELLOW}📋 Özet:${NC}"
echo "   - foto-ugur config'inden fikirtepetekelpaket.com temizlendi"
echo "   - fikirtepetekelpaket.com için ayrı config kontrol edildi"
echo "   - Nginx reload edildi"

