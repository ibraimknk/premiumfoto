#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr için Nginx ve SSL düzeltme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
FIKIRTEPE_CONFIG="/etc/nginx/sites-available/fikirtepetekelpaket"
TARGET_PORT=3040

echo -e "${BLUE}🔧 dugunkarem.com ve dugunkarem.com.tr Nginx ve SSL düzeltiliyor...${NC}"
echo ""

# 1. fikirtepetekelpaket.com config'inden dugunkarem domain'lerini kaldır
echo -e "${YELLOW}1️⃣ fikirtepetekelpaket.com config'inden dugunkarem domain'leri kaldırılıyor...${NC}"
if [ -f "$FIKIRTEPE_CONFIG" ]; then
    sudo python3 << PYEOF
import re

config_file = "$FIKIRTEPE_CONFIG"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# dugunkarem.com ve dugunkarem.com.tr'yi server_name'lerden kaldır
content = re.sub(
    r'\bdugunkarem\.com\b',
    '',
    content
)
content = re.sub(
    r'\bdugunkarem\.com\.tr\b',
    '',
    content
)

# Boş server_name satırlarını temizle
content = re.sub(r'server_name\s+;', 'server_name fikirtepetekelpaket.com;', content)
content = re.sub(r'server_name\s+\s+', 'server_name fikirtepetekelpaket.com;', content)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF
    echo -e "${GREEN}✅ fikirtepetekelpaket.com config güncellendi${NC}"
else
    echo -e "${YELLOW}⚠️  fikirtepetekelpaket.com config bulunamadı${NC}"
fi
echo ""

# 2. foto-ugur config'inde dugunkarem.com için SSL sertifikası kontrolü
echo -e "${YELLOW}2️⃣ SSL sertifikası kontrol ediliyor...${NC}"
CERT_PATH="/etc/letsencrypt/live/fotougur.com.tr"
if [ -f "${CERT_PATH}/fullchain.pem" ]; then
    echo -e "${GREEN}✅ Sertifika bulundu: ${CERT_PATH}${NC}"
    
    # Sertifikadaki domain'leri kontrol et
    CERT_DOMAINS=$(sudo openssl x509 -in ${CERT_PATH}/fullchain.pem -noout -text | grep -A 1 "Subject Alternative Name" | grep DNS | sed 's/DNS://g' | tr ',' '\n' | tr -d ' ' | tr '\n' ' ')
    echo -e "${YELLOW}   Sertifikadaki domain'ler: ${CERT_DOMAINS}${NC}"
    
    if echo "$CERT_DOMAINS" | grep -q "dugunkarem.com"; then
        echo -e "${GREEN}   ✅ dugunkarem.com sertifikada var${NC}"
    else
        echo -e "${YELLOW}   ⚠️  dugunkarem.com sertifikada yok, genişletiliyor...${NC}"
        sudo certbot certonly --nginx --expand -d fotougur.com.tr -d www.fotougur.com.tr -d dugunkarem.com -d www.dugunkarem.com -d dugunkarem.com.tr -d www.dugunkarem.com.tr --non-interactive --agree-tos --email info@fotougur.com.tr || echo "Sertifika genişletme başarısız, mevcut sertifika kullanılacak"
    fi
else
    echo -e "${RED}❌ Sertifika bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Sertifika oluşturuluyor...${NC}"
    sudo certbot certonly --nginx -d fotougur.com.tr -d www.fotougur.com.tr -d dugunkarem.com -d www.dugunkarem.com -d dugunkarem.com.tr -d www.dugunkarem.com.tr --non-interactive --agree-tos --email info@fotougur.com.tr || echo "Sertifika oluşturma başarısız"
fi
echo ""

# 3. foto-ugur config'inde dugunkarem.com server block'larını kontrol et ve düzelt
echo -e "${YELLOW}3️⃣ foto-ugur config'inde dugunkarem.com server block'ları kontrol ediliyor...${NC}"
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT
cert_path = "/etc/letsencrypt/live/fotougur.com.tr"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# dugunkarem.com için HTTPS server block var mı kontrol et
has_dugunkarem_com_https = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+443',
    content,
    re.DOTALL | re.IGNORECASE
))

has_dugunkarem_com_tr_https = bool(re.search(
    r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\.tr\b[^}]*listen\s+443',
    content,
    re.DOTALL | re.IGNORECASE
))

if not has_dugunkarem_com_https or not has_dugunkarem_com_tr_https:
    # Server block'ları ekle
    new_blocks = []
    
    if not has_dugunkarem_com_https:
        new_blocks.append(f'''
# dugunkarem.com SSL yapılandırması (Port {target_port})
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com www.dugunkarem.com;

    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    location /uploads {{
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }}

    location / {{
        proxy_pass http://127.0.0.1:{target_port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
''')
    
    if not has_dugunkarem_com_tr_https:
        new_blocks.append(f'''
# dugunkarem.com.tr SSL yapılandırması (Port {target_port})
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;

    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 50M;

    location /uploads {{
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }}

    location / {{
        proxy_pass http://127.0.0.1:{target_port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
}}
''')
    
    # Server block'ları dosyanın başına ekle
    first_server_match = re.search(r'server\s*\{', content)
    if first_server_match:
        insert_pos = first_server_match.start()
        content = content[:insert_pos] + '\n'.join(new_blocks) + '\n' + content[insert_pos:]
        print(f"{len(new_blocks)} server block eklendi")
    else:
        content = content + '\n'.join(new_blocks)
        print(f"{len(new_blocks)} server block eklendi")
else:
    print("Server block'lar zaten mevcut")

# Mevcut dugunkarem.com block'larındaki proxy_pass'leri kontrol et ve düzelt
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:3001',
    f'proxy_pass http://127.0.0.1:{target_port}',
    content
)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# 4. Nginx test ve reload
echo ""
echo -e "${YELLOW}4️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    sudo nginx -t
    exit 1
fi

# 5. Test
echo ""
echo -e "${YELLOW}5️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr")
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

