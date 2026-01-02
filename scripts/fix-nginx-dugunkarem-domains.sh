#!/bin/bash

# foto-ugur Nginx config'ine dugunkarem.com ve dugunkarem.com.tr ekle
# Bu script sudo gerektirmez, doğrudan dosyayı düzenler

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔧 foto-ugur Nginx config'ine dugunkarem domainleri ekleniyor...${NC}"

# Python3 ile dosyayı düzenle (sudo gerektirmez, root olarak çalıştırılmalı)
python3 << 'PYEOF'
import re
import sys

config_file = "/etc/nginx/sites-available/foto-ugur"

try:
    with open(config_file, 'r') as f:
        content = f.read()
    
    # server_name satırını bul ve güncelle
    # Eğer dugunkarem.com yoksa ekle
    pattern = r'(server_name\s+)([^;]+)(;)'
    
    def replace_server_name(match):
        server_name_keyword = match.group(1)
        domains = match.group(2).strip()
        semicolon = match.group(3)
        
        # dugunkarem.com ve dugunkarem.com.tr'yi kontrol et
        has_dugunkarem_com = 'dugunkarem.com' in domains
        has_dugunkarem_com_tr = 'dugunkarem.com.tr' in domains
        
        # dugunkarem.com ve dugunkarem.com.tr'yi ekle (yoksa)
        if not has_dugunkarem_com:
            domains += " dugunkarem.com www.dugunkarem.com"
        if not has_dugunkarem_com_tr:
            domains += " dugunkarem.com.tr www.dugunkarem.com.tr"
        
        return f"{server_name_keyword}{domains}{semicolon}"
    
    # Tüm server_name satırlarını güncelle
    new_content = re.sub(pattern, replace_server_name, content)
    
    # Eğer değişiklik yapıldıysa kaydet
    if new_content != content:
        with open(config_file, 'w') as f:
            f.write(new_content)
        print("✅ Nginx config güncellendi")
    else:
        print("ℹ️  Config zaten güncel")
        
except PermissionError:
    print("❌ Dosyaya yazma izni yok. Script'i root olarak çalıştırın veya sudo kullanın.")
    sys.exit(1)
except Exception as e:
    print(f"❌ Hata: {e}")
    sys.exit(1)
PYEOF

echo -e "${GREEN}✅ İşlem tamamlandı${NC}"
echo ""
echo -e "${YELLOW}📋 Kontrol:${NC}"
echo "   cat $FOTO_UGUR_CONFIG | grep server_name"
echo ""
echo -e "${YELLOW}🔄 Nginx test ve reload:${NC}"
echo "   nginx -t && systemctl reload nginx"

