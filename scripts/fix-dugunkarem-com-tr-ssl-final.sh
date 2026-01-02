#!/bin/bash

# dugunkarem.com.tr için SSL sertifikasını kesin olarak düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOMAIN="dugunkarem.com.tr"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
CERT_PATH="/etc/letsencrypt/live/dugunkarem.com"

echo -e "${YELLOW}🔧 ${DOMAIN} için SSL sertifikası kesin olarak düzeltiliyor...${NC}"

# 1. fikirtepetekelpaket.com config'inden dugunkarem.com.tr'yi kaldır
echo -e "${YELLOW}🔧 fikirtepetekelpaket.com config'inden ${DOMAIN} kaldırılıyor...${NC}"

FIKIRTEPETEKELPAKET_CONFIG="/etc/nginx/sites-available/fikirtepetekelpaket.com"
if [ -f "$FIKIRTEPETEKELPAKET_CONFIG" ]; then
    if sudo grep -q "${DOMAIN}" "$FIKIRTEPETEKELPAKET_CONFIG"; then
        echo -e "${YELLOW}📝 ${DOMAIN} bulundu, kaldırılıyor...${NC}"
        sudo sed -i "s/\b${DOMAIN}\b//g" "$FIKIRTEPETEKELPAKET_CONFIG"
        sudo sed -i "s/\bwww\.${DOMAIN}\b//g" "$FIKIRTEPETEKELPAKET_CONFIG"
        sudo sed -i "s/  */ /g" "$FIKIRTEPETEKELPAKET_CONFIG"  # Çoklu boşlukları temizle
        echo -e "${GREEN}✅ ${DOMAIN} kaldırıldı${NC}"
    fi
fi

# 2. foto-ugur config'inde dugunkarem.com.tr için ayrı SSL server block oluştur (en üste)
echo -e "${YELLOW}📝 foto-ugur config'inde ${DOMAIN} için SSL server block oluşturuluyor...${NC}"

sudo python3 << PYEOF
import re

config_file = "${FOTO_UGUR_CONFIG}"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com.tr için özel SSL server block'u var mı kontrol et
has_dugunkarem_ssl_block = re.search(r'# dugunkarem\.com\.tr SSL', content)

if not has_dugunkarem_ssl_block:
    # En başa dugunkarem.com.tr için SSL server block ekle
    ssl_block = f'''# dugunkarem.com.tr SSL yapılandırması (Port 3040 - premiumfoto)
server {{
    listen 443 ssl http2;
    server_name {DOMAIN} www.{DOMAIN};
    
    ssl_certificate ${CERT_PATH}/fullchain.pem;
    ssl_certificate_key ${CERT_PATH}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    client_max_body_size 50M;
    
    location /uploads {{
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
        try_files $uri =404;
    }}
    
    location / {{
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }}
}}

'''
    # Dosyanın başına ekle
    content = ssl_block + content
    print("✅ SSL server block eklendi")
else:
    print("ℹ️  SSL server block zaten mevcut, güncelleniyor...")
    # Mevcut block'u güncelle
    pattern = r'(# dugunkarem\.com\.tr SSL[^}]*server\s*\{[^}]*listen\s+443[^}]*server_name[^}]*' + re.escape(DOMAIN) + r'[^}]*)(.*?)(\})'
    
    def update_ssl_block(match):
        block_start = match.group(1)
        block_content = match.group(2)
        block_end = match.group(3)
        
        # SSL sertifika path'lerini düzelt
        block_start = re.sub(r'ssl_certificate\s+[^;]+;', f'ssl_certificate ${CERT_PATH}/fullchain.pem;', block_start)
        block_start = re.sub(r'ssl_certificate_key\s+[^;]+;', f'ssl_certificate_key ${CERT_PATH}/privkey.pem;', block_start)
        
        # proxy_pass kontrolü
        if 'proxy_pass' not in block_content:
            location_block = '''
    location / {
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
'''
            block_content = location_block + block_content
        
        return block_start + block_content + block_end
    
    content = re.sub(pattern, update_ssl_block, content, flags=re.DOTALL)

# Ana server block'undan dugunkarem.com.tr'yi kaldır (çakışmayı önlemek için)
content = re.sub(r'(server_name[^;]*)\b' + re.escape(DOMAIN) + r'\b([^;]*;)', r'\1\2', content)
content = re.sub(r'(server_name[^;]*)\bwww\.' + re.escape(DOMAIN) + r'\b([^;]*;)', r'\1\2', content)
content = re.sub(r'  +', ' ', content)  # Çoklu boşlukları temizle

# Çoklu boş satırları temizle
content = re.sub(r'\n\n\n+', '\n\n', content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ Config güncellendi")
PYEOF

# 3. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ ${DOMAIN} için SSL sertifikası kesin olarak düzeltildi!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} < /dev/null 2>/dev/null | openssl x509 -noout -subject"
echo "   # Artık şunu görmeli: subject=CN = dugunkarem.com"

