#!/bin/bash

# dugunkarem.com SSL yapılandırmasını Nginx'e ekle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"

echo -e "${YELLOW}🔒 dugunkarem.com SSL yapılandırması Nginx'e ekleniyor...${NC}"

if [ ! -f "$FOTO_UGUR_CONFIG" ]; then
    echo -e "${RED}❌ foto-ugur config bulunamadı: $FOTO_UGUR_CONFIG${NC}"
    exit 1
fi

# Sertifika kontrolü
if [ ! -f "$CERT_PATH/fullchain.pem" ] || [ ! -f "$CERT_PATH/privkey.pem" ]; then
    echo -e "${RED}❌ SSL sertifikası bulunamadı: $CERT_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ SSL sertifikası bulundu${NC}"

# Config yedekle
sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Config yedeklendi${NC}"

# Önce www. www. gibi tekrarları temizle
echo -e "${YELLOW}🧹 Config temizleniyor...${NC}"
sudo sed -i 's/www\. www\./www.fotougur.com.tr/g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/server_name  */server_name /g' "$FOTO_UGUR_CONFIG"
sudo sed -i 's/ ;/;/g' "$FOTO_UGUR_CONFIG"

# 443 portu için SSL yapılandırması var mı kontrol et
if grep -q "listen 443 ssl" "$FOTO_UGUR_CONFIG"; then
    echo -e "${YELLOW}⚠️  SSL yapılandırması zaten mevcut${NC}"
    
    # dugunkarem.com için ayrı bir 443 server block var mı kontrol et
    if ! grep -A 5 "listen 443 ssl" "$FOTO_UGUR_CONFIG" | grep -q "dugunkarem\.com"; then
        echo -e "${YELLOW}📝 dugunkarem.com için SSL yapılandırması ekleniyor...${NC}"
        
        # Python ile config'e dugunkarem.com için 443 server block ekle
        sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# 80 portu için server block'u bul (dugunkarem içeren)
match_80 = re.search(r'(server\s*\{[^}]*server_name[^}]*dugunkarem[^}]*listen\s+80[^}]*\})', content, re.DOTALL)
if match_80:
    server_block_80 = match_80.group(1)
    
    # 443 için server block oluştur
    server_block_443 = server_block_80.replace('listen 80;', '''listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/dugunkarem.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dugunkarem.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;''')
    
    # Sadece dugunkarem domain'lerini tut
    server_block_443 = re.sub(r'server_name[^;]+;', 'server_name dugunkarem.com dugunkarem.com.tr;', server_block_443)
    
    # Config'in sonuna ekle (80 portu redirect'inden önce)
    # Önce 80 portu redirect block'unu bul
    redirect_match = re.search(r'(server\s*\{[^}]*if.*dugunkarem[^}]*\})', content, re.DOTALL)
    if redirect_match:
        # Redirect block'undan önce ekle
        redirect_pos = redirect_match.start()
        content = content[:redirect_pos] + server_block_443 + "\n\n" + content[redirect_pos:]
    else:
        # Sonuna ekle
        content = content.rstrip() + "\n\n" + server_block_443
    
    with open(config_file, 'w') as f:
        f.write(content)
    
    print("✅ dugunkarem.com için SSL yapılandırması eklendi")
else:
    print("⚠️ 80 portu için dugunkarem server block bulunamadı, manuel ekleme gerekebilir")
PYEOF
    else
        echo -e "${GREEN}✅ dugunkarem.com için SSL yapılandırması zaten mevcut${NC}"
    fi
else
    echo -e "${YELLOW}📝 SSL yapılandırması ekleniyor...${NC}"
    
    # 80 portu için server block'u bul ve 443 için kopyala
    sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r') as f:
    content = f.read()

# 80 portu için server block'u bul (dugunkarem içeren)
match_80 = re.search(r'(server\s*\{[^}]*server_name[^}]*dugunkarem[^}]*listen\s+80[^}]*\})', content, re.DOTALL)
if match_80:
    server_block_80 = match_80.group(1)
    
    # 443 için server block oluştur
    server_block_443 = server_block_80.replace('listen 80;', '''listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/dugunkarem.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dugunkarem.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;''')
    
    # Sadece dugunkarem domain'lerini tut
    server_block_443 = re.sub(r'server_name[^;]+;', 'server_name dugunkarem.com dugunkarem.com.tr;', server_block_443)
    
    # Config'in sonuna ekle
    content = content.rstrip() + "\n\n" + server_block_443
    
    with open(config_file, 'w') as f:
        f.write(content)
    
    print("✅ SSL yapılandırması eklendi")
else:
    print("❌ 80 portu için dugunkarem server block bulunamadı!")
    exit(1)
PYEOF
fi

# HTTP'den HTTPS'e yönlendirme kontrolü
if ! grep -q "if (\$host = dugunkarem.com)" "$FOTO_UGUR_CONFIG"; then
    echo -e "${YELLOW}📝 HTTP'den HTTPS'e yönlendirme ekleniyor...${NC}"
    
    # 80 portu için redirect block ekle
    redirect_block='''
server {
    if ($host = dugunkarem.com) {
        return 301 https://$host$request_uri;
    }
    if ($host = dugunkarem.com.tr) {
        return 301 https://$host$request_uri;
    }
    listen 80;
    server_name dugunkarem.com dugunkarem.com.tr;
    return 404;
}
'''
    
    sudo bash -c "echo '$redirect_block' >> $FOTO_UGUR_CONFIG"
    echo -e "${GREEN}✅ Yönlendirme eklendi${NC}"
fi

# Nginx test
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config OK${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
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

