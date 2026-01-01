#!/bin/bash

# foto-ugur config'inden dugunkarem.com'u kaldır (443 portu için)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 foto-ugur config'inden dugunkarem.com kaldırılıyor...${NC}"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# 443 portu için server block'undan dugunkarem.com'u kaldır
echo -e "${YELLOW}📝 443 portu için server block düzeltiliyor...${NC}"

sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# 443 portu için server block'u bul (fotougur.com.tr sertifikası kullanan)
# Bu block'tan dugunkarem.com ve dugunkarem.com.tr'yi kaldır
pattern = r'(server\s*\{[^}]*listen\s+443\s+ssl[^}]*server_name\s+)([^;]+)(;[^}]*ssl_certificate[^}]*fotougur\.com\.tr[^}]*\})'

def remove_dugunkarem(match):
    server_start = match.group(1)
    server_names = match.group(2)
    server_end = match.group(3)
    
    # dugunkarem domain'lerini kaldır
    server_names = re.sub(r'\s*dugunkarem\.com\.tr\s*', ' ', server_names)
    server_names = re.sub(r'\s*dugunkarem\.com\s*', ' ', server_names)
    server_names = re.sub(r'\s+', ' ', server_names).strip()
    
    return server_start + server_names + server_end

content = re.sub(pattern, remove_dugunkarem, content, flags=re.DOTALL)

# 80 portu için server block'undan da kaldır (eğer varsa)
pattern = r'(server\s*\{[^}]*listen\s+80[^}]*server_name\s+)([^;]+)(;[^}]*fotougur[^}]*\})'

def remove_dugunkarem_80(match):
    server_start = match.group(1)
    server_names = match.group(2)
    server_end = match.group(3)
    
    # dugunkarem domain'lerini kaldır
    server_names = re.sub(r'\s*dugunkarem\.com\.tr\s*', ' ', server_names)
    server_names = re.sub(r'\s*dugunkarem\.com\s*', ' ', server_names)
    server_names = re.sub(r'\s+', ' ', server_names).strip()
    
    return server_start + server_names + server_end

content = re.sub(pattern, remove_dugunkarem_80, content, flags=re.DOTALL)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ dugunkarem.com foto-ugur config'inden kaldırıldı")
PYEOF

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
echo -e "${GREEN}✅ dugunkarem.com foto-ugur config'inden kaldırıldı!${NC}"
echo -e "${YELLOW}📋 Artık dugunkarem.com sadece kendi SSL yapılandırmasını kullanacak${NC}"

