#!/bin/bash

# Nginx config'deki proxy_set_header hatalarını düzeltme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_FILE="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🔧 Nginx proxy_set_header hataları düzeltiliyor...${NC}"
echo ""

# Yedek al
echo -e "${YELLOW}📋 Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo -e "${GREEN}✅ Yedek alındı: ${BACKUP_FILE}${NC}"
echo ""

# 56. satırı kontrol et
echo -e "${YELLOW}🔍 56. satır kontrol ediliyor...${NC}"
LINE_56=$(sudo sed -n '56p' "$NGINX_CONFIG")
echo -e "${BLUE}56. satır: ${LINE_56}${NC}"
echo ""

# Python script ile düzelt
echo -e "${YELLOW}🔧 proxy_set_header hataları düzeltiliyor...${NC}"
sudo python3 << PYEOF
import re
import sys

config_file = "${NGINX_CONFIG}"

try:
    with open(config_file, 'r') as f:
        lines = f.readlines()
    
    fixed_lines = []
    errors_found = []
    
    for i, line in enumerate(lines, 1):
        original_line = line
        
        # proxy_set_header satırlarını kontrol et
        if 'proxy_set_header' in line:
            # Eğer satırda $ karakteri eksik veya yanlışsa düzelt
            # Örnek: proxy_set_header Host host; -> proxy_set_header Host $host;
            
            # Host header'ı düzelt
            if 'proxy_set_header Host' in line and '$host' not in line.lower():
                line = re.sub(r'proxy_set_header\s+Host\s+([^;]+);', r'proxy_set_header Host $host;', line)
                errors_found.append(f"Satır {i}: Host header düzeltildi")
            
            # X-Real-IP header'ı düzelt
            if 'proxy_set_header X-Real-IP' in line and '$remote_addr' not in line.lower():
                line = re.sub(r'proxy_set_header\s+X-Real-IP\s+([^;]+);', r'proxy_set_header X-Real-IP $remote_addr;', line)
                errors_found.append(f"Satır {i}: X-Real-IP header düzeltildi")
            
            # X-Forwarded-For header'ı düzelt
            if 'proxy_set_header X-Forwarded-For' in line and '$proxy_add_x_forwarded_for' not in line.lower():
                line = re.sub(r'proxy_set_header\s+X-Forwarded-For\s+([^;]+);', r'proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;', line)
                errors_found.append(f"Satır {i}: X-Forwarded-For header düzeltildi")
            
            # X-Forwarded-Proto header'ı düzelt
            if 'proxy_set_header X-Forwarded-Proto' in line and '$scheme' not in line.lower():
                line = re.sub(r'proxy_set_header\s+X-Forwarded-Proto\s+([^;]+);', r'proxy_set_header X-Forwarded-Proto $scheme;', line)
                errors_found.append(f"Satır {i}: X-Forwarded-Proto header düzeltildi")
            
            # Upgrade header'ı düzelt
            if 'proxy_set_header Upgrade' in line and '$http_upgrade' not in line.lower():
                line = re.sub(r'proxy_set_header\s+Upgrade\s+([^;]+);', r'proxy_set_header Upgrade $http_upgrade;', line)
                errors_found.append(f"Satır {i}: Upgrade header düzeltildi")
            
            # Eğer satırda sadece 2 argüman varsa (eksik değer), satırı kaldır
            parts = line.split()
            if len(parts) == 2 and 'proxy_set_header' in parts[0]:
                print(f"⚠️  Satır {i}: Eksik proxy_set_header satırı kaldırılıyor: {line.strip()}")
                continue
        
        fixed_lines.append(line)
    
    if errors_found:
        print("✅ Düzeltilen hatalar:")
        for error in errors_found:
            print(f"   - {error}")
    else:
        print("✅ proxy_set_header hataları bulunamadı")
    
    # Config'i kaydet
    with open(config_file, 'w') as f:
        f.writelines(fixed_lines)
    
    print("✅ Nginx config düzeltildi")
    
except Exception as e:
    print(f"❌ Hata: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
PYEOF

echo ""

# Nginx test
echo -e "${YELLOW}🔍 Nginx config test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}📋 Hata detayları:${NC}"
    sudo nginx -t 2>&1 | head -20
    echo ""
    echo -e "${YELLOW}💡 56. satırı kontrol edin:${NC}"
    sudo sed -n '54,58p' "$NGINX_CONFIG"
    echo ""
    echo -e "${RED}❌ Yedekten geri yükleniyor...${NC}"
    sudo cp "$BACKUP_FILE" "$NGINX_CONFIG"
    exit 1
fi
echo ""

# Nginx reload
echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
sudo systemctl reload nginx
echo -e "${GREEN}✅ Nginx reload edildi${NC}"
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ proxy_set_header Hataları Düzeltildi!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

