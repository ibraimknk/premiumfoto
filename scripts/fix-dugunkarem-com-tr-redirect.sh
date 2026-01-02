#!/bin/bash

# dugunkarem.com.tr'nin port 3040'a (premiumfoto) yönlendirildiğinden emin ol

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="dugunkarem.com.tr"
TARGET_PORT=3040
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 ${DOMAIN} yönlendirmesi düzeltiliyor...${NC}"

# 1. Tüm Nginx config'lerinde dugunkarem.com.tr'yi bul
echo -e "${YELLOW}🔍 Tüm config'lerde ${DOMAIN} aranıyor...${NC}"

CONFIG_FILES=$(sudo find /etc/nginx/sites-available -type f -name "*.com" 2>/dev/null)

for config in $CONFIG_FILES; do
    if sudo grep -q "${DOMAIN}" "$config" 2>/dev/null; then
        echo -e "${YELLOW}📝 Bulundu: $config${NC}"
        echo -e "${YELLOW}   İçerik:${NC}"
        sudo grep -n "${DOMAIN}" "$config" | head -5
    fi
done

# 2. foto-ugur config'inde dugunkarem.com.tr kontrolü
echo -e "${YELLOW}📝 foto-ugur config kontrol ediliyor...${NC}"

if sudo grep -q "${DOMAIN}" "$FOTO_UGUR_CONFIG"; then
    # proxy_pass port'unu kontrol et
    PROXY_PASS=$(sudo grep -A 10 "${DOMAIN}" "$FOTO_UGUR_CONFIG" | grep "proxy_pass" | head -1)
    
    if echo "$PROXY_PASS" | grep -q ":${TARGET_PORT}"; then
        echo -e "${GREEN}✅ ${DOMAIN} zaten port ${TARGET_PORT}'a yönlendiriliyor${NC}"
    else
        echo -e "${YELLOW}⚠️  ${DOMAIN} yanlış porta yönlendiriliyor, düzeltiliyor...${NC}"
        
        # Python ile düzelt
        sudo python3 << PYEOF
import re

config_file = "${FOTO_UGUR_CONFIG}"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com.tr içeren server block'unda proxy_pass'i düzelt
# Önce server block'unu bul
pattern = r'(server\s*\{[^}]*server_name[^}]*${DOMAIN}[^}]*location\s+/\s*\{[^}]*proxy_pass\s+)(http://[^:]+:)(\d+)([^;]+);'

def fix_proxy_pass(match):
    prefix = match.group(1)
    http_prefix = match.group(2)
    old_port = match.group(3)
    suffix = match.group(4)
    
    # Port'u 3040 yap
    return f"{prefix}{http_prefix}${TARGET_PORT}{suffix};"

content = re.sub(pattern, fix_proxy_pass, content, flags=re.DOTALL)

# Eğer dugunkarem.com.tr için ayrı bir server block varsa ve proxy_pass yoksa ekle
if "${DOMAIN}" in content and "proxy_pass" not in content.split("${DOMAIN}")[1].split("}")[0]:
    # Server block'unu bul ve proxy_pass ekle
    pattern2 = r'(server\s*\{[^}]*server_name[^}]*${DOMAIN}[^}]*location\s+/\s*\{)([^}]*)(\})'
    
    def add_proxy_pass(match):
        location_start = match.group(1)
        location_content = match.group(2)
        location_end = match.group(3)
        
        if "proxy_pass" not in location_content:
            proxy_config = '''
        proxy_pass http://127.0.0.1:${TARGET_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
'''
            location_content = proxy_config + location_content
        
        return location_start + location_content + location_end
    
    content = re.sub(pattern2, add_proxy_pass, content, flags=re.DOTALL)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ Config güncellendi")
PYEOF
    fi
else
    echo -e "${YELLOW}⚠️  ${DOMAIN} foto-ugur config'inde bulunamadı, ekleniyor...${NC}"
    
    # foto-ugur config'ine dugunkarem.com.tr ekle
    sudo python3 << PYEOF
import re

config_file = "${FOTO_UGUR_CONFIG}"

with open(config_file, 'r') as f:
    content = f.read()

# server_name satırını bul ve dugunkarem.com.tr ekle
pattern = r'(server_name\s+)([^;]+)(;)'

def add_domain(match):
    server_name_keyword = match.group(1)
    domains = match.group(2).strip()
    semicolon = match.group(3)
    
    # dugunkarem.com.tr yoksa ekle
    if "${DOMAIN}" not in domains:
        domains += " ${DOMAIN} www.${DOMAIN}"
    
    return f"{server_name_keyword}{domains}{semicolon}"

content = re.sub(pattern, add_domain, content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ ${DOMAIN} eklendi")
PYEOF
fi

# 3. Diğer config'lerden dugunkarem.com.tr'yi kaldır (fikirtepetekelpaket.com hariç)
echo -e "${YELLOW}🔧 Diğer config'lerden ${DOMAIN} kaldırılıyor...${NC}"

for config in $CONFIG_FILES; do
    if [ "$config" != "$FOTO_UGUR_CONFIG" ] && [ "$config" != "/etc/nginx/sites-available/fikirtepetekelpaket.com" ]; then
        if sudo grep -q "${DOMAIN}" "$config" 2>/dev/null; then
            echo -e "${YELLOW}🗑️  ${DOMAIN} kaldırılıyor: $config${NC}"
            
            sudo python3 << PYEOF
import re

config_file = "$config"

with open(config_file, 'r') as f:
    content = f.read()

# server_name'den dugunkarem.com.tr'yi kaldır
pattern = r'(server_name\s+)([^;]+)(;)'

def remove_domain(match):
    server_name_keyword = match.group(1)
    domains = match.group(2).strip()
    semicolon = match.group(3)
    
    # dugunkarem.com.tr ve www.dugunkarem.com.tr'yi kaldır
    domains = re.sub(r'\b${DOMAIN}\b', '', domains)
    domains = re.sub(r'\bwww\.${DOMAIN}\b', '', domains)
    domains = re.sub(r'\s+', ' ', domains).strip()
    
    return f"{server_name_keyword}{domains}{semicolon}"

content = re.sub(pattern, remove_domain, content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ ${DOMAIN} kaldırıldı")
PYEOF
        fi
    fi
done

# 4. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ ${DOMAIN} yönlendirmesi düzeltildi!${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol:${NC}"
echo "   curl -I https://${DOMAIN}"
echo "   sudo cat ${FOTO_UGUR_CONFIG} | grep -A 5 '${DOMAIN}'"

