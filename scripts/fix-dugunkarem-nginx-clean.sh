#!/bin/bash

# dugunkarem domain'lerini foto-ugur config'inden temizle ve düzgün ekle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🧹 dugunkarem domain'leri temizleniyor ve düzgün ekleniyor...${NC}"

if [ ! -f "$FOTO_UGUR_CONFIG" ]; then
    echo -e "${RED}❌ foto-ugur config bulunamadı: $FOTO_UGUR_CONFIG${NC}"
    exit 1
fi

# Mevcut server_name satırını bul
SERVER_NAME_LINE=$(grep -n "server_name" "$FOTO_UGUR_CONFIG" | head -1)
if [ -z "$SERVER_NAME_LINE" ]; then
    echo -e "${RED}❌ server_name satırı bulunamadı!${NC}"
    exit 1
fi

# Tüm dugunkarem domain'lerini kaldır (www dahil)
echo -e "${YELLOW}🗑️  Tüm dugunkarem domain'leri kaldırılıyor...${NC}"
sudo sed -i "s/dugunkarem\.com\.tr//g" "$FOTO_UGUR_CONFIG"
sudo sed -i "s/www\.dugunkarem\.com\.tr//g" "$FOTO_UGUR_CONFIG"
sudo sed -i "s/dugunkarem\.com//g" "$FOTO_UGUR_CONFIG"
sudo sed -i "s/www\.dugunkarem\.com//g" "$FOTO_UGUR_CONFIG"

# Çoklu boşlukları tek boşluğa indir
sudo sed -i 's/  */ /g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/server_name  */server_name /g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/ ;/;/g' "$FOTO_UGUR_CONFIG"

# Mevcut server_name'i al (temizlemeden sonra)
CURRENT_SERVER_NAME=$(grep "server_name" "$FOTO_UGUR_CONFIG" | head -1 | sed 's/server_name//' | sed 's/;//' | xargs)

# dugunkarem.com ve dugunkarem.com.tr ekle (eğer yoksa)
if ! echo "$CURRENT_SERVER_NAME" | grep -q "dugunkarem\.com"; then
    NEW_SERVER_NAME="$CURRENT_SERVER_NAME dugunkarem.com dugunkarem.com.tr"
    sudo sed -i "s/server_name.*;/server_name $NEW_SERVER_NAME;/" "$FOTO_UGUR_CONFIG"
    echo -e "${GREEN}✅ dugunkarem domain'leri eklendi${NC}"
else
    echo -e "${YELLOW}⚠️ dugunkarem domain'leri zaten mevcut${NC}"
fi

# Son kontrol - tekrar eden domain'leri kaldır
echo -e "${YELLOW}🔍 Tekrar eden domain'ler kontrol ediliyor...${NC}"

# Python script ile unique domain'leri al
python3 << 'PYEOF'
import re
import sys

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# server_name satırını bul
match = re.search(r'server_name\s+([^;]+);', content)
if match:
    domains = match.group(1).split()
    # Unique domain'leri al
    unique_domains = []
    seen = set()
    for domain in domains:
        domain = domain.strip()
        if domain and domain not in seen:
            unique_domains.append(domain)
            seen.add(domain)
    
    # server_name satırını güncelle
    new_server_name = "server_name " + " ".join(unique_domains) + ";"
    content = re.sub(r'server_name\s+[^;]+;', new_server_name, content)
    
    with open(config_file, 'w') as f:
        f.write(content)
    
    print("✅ Tekrar eden domain'ler temizlendi")
    print(f"📋 Domain'ler: {' '.join(unique_domains)}")
else:
    print("❌ server_name satırı bulunamadı!")
    sys.exit(1)
PYEOF

# Nginx test
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
    echo ""
    echo -e "${YELLOW}📋 Güncel server_name:${NC}"
    sudo grep "server_name" "$FOTO_UGUR_CONFIG" | head -1
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Temizleme tamamlandı!${NC}"
echo -e "${YELLOW}💡 Şimdi şu komutu çalıştırın:${NC}"
echo "   sudo systemctl reload nginx"
echo "   sudo certbot --nginx -d dugunkarem.com -d dugunkarem.com.tr --non-interactive --agree-tos --email ibrahim@example.com"

