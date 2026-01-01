#!/bin/bash

# dugunkarem.com SSL sertifikasını Nginx'e manuel olarak kur

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${YELLOW}🔒 dugunkarem.com SSL sertifikası Nginx'e kuruluyor...${NC}"

if [ ! -f "$FOTO_UGUR_CONFIG" ]; then
    echo -e "${RED}❌ foto-ugur config bulunamadı: $FOTO_UGUR_CONFIG${NC}"
    exit 1
fi

# Sertifika dosyalarının varlığını kontrol et
CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"
if [ ! -f "$CERT_PATH/fullchain.pem" ] || [ ! -f "$CERT_PATH/privkey.pem" ]; then
    echo -e "${RED}❌ SSL sertifikası bulunamadı: $CERT_PATH${NC}"
    echo -e "${YELLOW}💡 Önce sertifikayı oluşturun:${NC}"
    echo "   sudo certbot --nginx -d dugunkarem.com -d dugunkarem.com.tr --expand"
    exit 1
fi

echo -e "${GREEN}✅ SSL sertifikası bulundu${NC}"

# Mevcut config'i yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Config yedeklendi${NC}"

# SSL yapılandırmasını ekle
# Önce 443 portu için server block var mı kontrol et
if grep -q "listen 443 ssl" "$FOTO_UGUR_CONFIG"; then
    echo -e "${YELLOW}⚠️  SSL yapılandırması zaten mevcut, güncelleniyor...${NC}"
    
    # Mevcut SSL sertifika path'lerini dugunkarem.com için güncelle
    sudo sed -i "s|ssl_certificate.*|ssl_certificate $CERT_PATH/fullchain.pem;|" "$FOTO_UGUR_CONFIG"
    sudo sed -i "s|ssl_certificate_key.*|ssl_certificate_key $CERT_PATH/privkey.pem;|" "$FOTO_UGUR_CONFIG"
    
    echo -e "${GREEN}✅ SSL sertifika path'leri güncellendi${NC}"
else
    echo -e "${YELLOW}📝 SSL yapılandırması ekleniyor...${NC}"
    
    # 443 portu için server block ekle
    # Önce 80 portu için server block'u bul ve 443 için kopyala
    sudo python3 << 'PYEOF'
import re
import sys

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# 80 portu için server block'u bul
match = re.search(r'(server\s*\{[^}]*listen\s+80[^}]*\})', content, re.DOTALL)
if match:
    server_block_80 = match.group(1)
    
    # 443 için server block oluştur
    server_block_443 = server_block_80.replace('listen 80;', '''listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/dugunkarem.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dugunkarem.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;''')
    
    # 80 portu için HTTP'den HTTPS'e yönlendirme ekle
    redirect_block = '''server {
    if ($host = dugunkarem.com) {
        return 301 https://$host$request_uri;
    }
    if ($host = dugunkarem.com.tr) {
        return 301 https://$host$request_uri;
    }
    listen 80;
    server_name dugunkarem.com dugunkarem.com.tr;
    return 404;
}'''
    
    # Config'in sonuna ekle
    content = content.rstrip() + "\n\n" + server_block_443 + "\n\n" + redirect_block
    
    with open(config_file, 'w') as f:
        f.write(content)
    
    print("✅ SSL yapılandırması eklendi")
else:
    print("❌ 80 portu için server block bulunamadı!")
    sys.exit(1)
PYEOF
fi

# Nginx test
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
else
    echo -e "${RED}❌ Nginx config hatası! Yedekten geri yükleniyor...${NC}"
    sudo cp "${FOTO_UGUR_CONFIG}.backup."* "$FOTO_UGUR_CONFIG" 2>/dev/null || true
    exit 1
fi

# Nginx reload
echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
sudo systemctl reload nginx

echo ""
echo -e "${GREEN}✅ SSL kurulumu tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

