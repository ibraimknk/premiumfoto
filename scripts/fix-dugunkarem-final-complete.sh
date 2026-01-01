#!/bin/bash

# dugunkarem.com için final tam düzeltme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 dugunkarem.com için final tam düzeltme...${NC}"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# www.www.dugunkarem.com.tr kalıntısını temizle
echo -e "${YELLOW}🧹 www.www.dugunkarem.com.tr kalıntısı temizleniyor...${NC}"
sudo sed -i 's/www\.www\.dugunkarem\.com\.tr//g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/www\.www\.//g' "$FOTO_UGUR_CONFIG"

# Tüm dugunkarem kalıntılarını temizle (özel block hariç)
echo -e "${YELLOW}🧹 Tüm dugunkarem kalıntıları temizleniyor...${NC}"

sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# İlk server block'tan (fotougur.com.tr içeren) dugunkarem.com'u kaldır
# server_name satırını bul ve dugunkarem.com'u kaldır
lines = content.split('\n')
new_lines = []
in_first_server = False
first_server_start = -1

for i, line in enumerate(lines):
    if re.match(r'^\s*server\s*\{', line) and first_server_start == -1:
        in_first_server = True
        first_server_start = i
        new_lines.append(line)
    elif in_first_server and 'server_name' in line and 'fotougur.com.tr' in line:
        # dugunkarem.com'u kaldır
        line = re.sub(r'\s*www\.www\.dugunkarem\.com\.tr\s*', '', line)
        line = re.sub(r'\s*dugunkarem\.com\.tr\s*', '', line)
        line = re.sub(r'\s*dugunkarem\.com\s*', '', line)
        line = re.sub(r'\s+', ' ', line)
        line = re.sub(r' ;', ';', line)
        new_lines.append(line)
    elif in_first_server and re.match(r'^\s*\}', line):
        in_first_server = False
        first_server_start = -1
        new_lines.append(line)
    else:
        new_lines.append(line)

content = '\n'.join(new_lines)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ İlk server block'tan dugunkarem.com kaldırıldı")
PYEOF

# dugunkarem.com için server block'unun en başta olduğundan emin ol
if ! sudo head -5 "$FOTO_UGUR_CONFIG" | grep -q "dugunkarem.com SSL"; then
    echo -e "${YELLOW}📝 dugunkarem.com server block'u en başa taşınıyor...${NC}"
    
    # dugunkarem.com block'unu bul ve en başa taşı
    sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com için server block'u bul
pattern = r'(# dugunkarem\.com SSL yapılandırması\s*server\s*\{[^}]*server_name\s+dugunkarem\.com\s+dugunkarem\.com\.tr[^}]*listen\s+443[^}]*\}[^}]*\})'
match = re.search(pattern, content, re.DOTALL)

if match:
    dugunkarem_block = match.group(0)
    # Block'u içerikten kaldır
    content = content.replace(dugunkarem_block, "")
    # En başa ekle
    content = dugunkarem_block + "\n\n" + content
    print("✅ dugunkarem.com server block'u en başa taşındı")
else:
    print("⚠️  dugunkarem.com server block'u bulunamadı")

# HTTP redirect block'unu da bul ve en başa taşı
pattern_redirect = r'(# dugunkarem\.com HTTP[^}]*server\s*\{[^}]*server_name\s+dugunkarem\.com\s+dugunkarem\.com\.tr[^}]*listen\s+80[^}]*\})'
match_redirect = re.search(pattern_redirect, content, re.DOTALL)

if match_redirect:
    redirect_block = match_redirect.group(0)
    # Block'u içerikten kaldır
    content = content.replace(redirect_block, "")
    # dugunkarem SSL block'undan sonra ekle
    if match:
        content = content.replace(dugunkarem_block + "\n\n", dugunkarem_block + "\n\n" + redirect_block + "\n\n", 1)
    else:
        content = redirect_block + "\n\n" + content
    print("✅ dugunkarem.com redirect block'u da en başa taşındı")

with open(config_file, 'w') as f:
    f.write(content)
PYEOF
fi

# Nginx test
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Final düzeltme tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | openssl x509 -noout -subject"

