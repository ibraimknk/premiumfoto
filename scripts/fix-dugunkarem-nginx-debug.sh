#!/bin/bash

# dugunkarem.com için Nginx debug ve düzeltme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
TARGET_PORT=3040

echo -e "${BLUE}🔍 dugunkarem.com Nginx debug...${NC}"
echo ""

# 1. Tüm aktif Nginx config'lerini listele
echo -e "${YELLOW}1️⃣ Aktif Nginx config'leri:${NC}"
sudo ls -la /etc/nginx/sites-enabled/
echo ""

# 2. dugunkarem.com içeren tüm config dosyalarını bul
echo -e "${YELLOW}2️⃣ dugunkarem.com içeren config dosyaları:${NC}"
sudo grep -r "dugunkarem.com" /etc/nginx/sites-available/ /etc/nginx/sites-enabled/ 2>/dev/null | cut -d: -f1 | sort -u | while read config_file; do
    echo -e "${YELLOW}   📄 $config_file${NC}"
    sudo grep -A 5 "server_name.*dugunkarem.com" "$config_file" 2>/dev/null | head -10
    echo ""
done

# 3. Nginx'in hangi server block'unu kullandığını test et
echo -e "${YELLOW}3️⃣ Nginx server block test:${NC}"
sudo nginx -T 2>/dev/null | grep -A 20 "server_name.*dugunkarem.com" | head -30
echo ""

# 4. foto-ugur config'inde dugunkarem.com server block'larını kontrol et
echo -e "${YELLOW}4️⃣ foto-ugur config'inde dugunkarem.com server block'ları:${NC}"
sudo grep -B 5 -A 15 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | head -40
echo ""

# 5. Port 3040 kontrolü
echo -e "${YELLOW}5️⃣ Port ${TARGET_PORT} kontrolü:${NC}"
if curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:${TARGET_PORT} | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ Port ${TARGET_PORT} çalışıyor${NC}"
else
    echo -e "${RED}❌ Port ${TARGET_PORT} çalışmıyor!${NC}"
fi
echo ""

# 6. Nginx error log (dugunkarem ile ilgili)
echo -e "${YELLOW}6️⃣ Nginx error log (dugunkarem):${NC}"
sudo tail -20 /var/log/nginx/error.log | grep -i "dugunkarem\|3040" || echo "   dugunkarem ile ilgili hata yok"
echo ""

# 7. foto-ugur config'inde dugunkarem.com için server block'ları en başa taşı
echo -e "${YELLOW}7️⃣ dugunkarem.com server block'ları en başa taşınıyor...${NC}"
sudo python3 << PYEOF
import re

config_file = "$NGINX_CONFIG"
target_port = $TARGET_PORT
cert_path = "/etc/letsencrypt/live/fotougur.com.tr"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# dugunkarem.com için HTTP redirect block'u bul
http_redirect_pattern = r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+80[^}]*\}'
http_redirect_match = re.search(http_redirect_pattern, content, re.DOTALL | re.IGNORECASE)

# dugunkarem.com için HTTPS block'u bul
https_pattern = r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\b[^}]*listen\s+443[^}]*\}'
https_match = re.search(https_pattern, content, re.DOTALL | re.IGNORECASE)

# dugunkarem.com.tr için HTTP redirect block'u bul
http_redirect_tr_pattern = r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\.tr\b[^}]*listen\s+80[^}]*\}'
http_redirect_tr_match = re.search(http_redirect_tr_pattern, content, re.DOTALL | re.IGNORECASE)

# dugunkarem.com.tr için HTTPS block'u bul
https_tr_pattern = r'server\s*\{[^}]*server_name[^}]*\bdugunkarem\.com\.tr\b[^}]*listen\s+443[^}]*\}'
https_tr_match = re.search(https_tr_pattern, content, re.DOTALL | re.IGNORECASE)

# Bulunan block'ları topla
blocks_to_move = []
if http_redirect_match:
    blocks_to_move.append(http_redirect_match.group(0))
if http_redirect_tr_match:
    blocks_to_move.append(http_redirect_tr_match.group(0))
if https_match:
    blocks_to_move.append(https_match.group(0))
if https_tr_match:
    blocks_to_move.append(https_tr_match.group(0))

if blocks_to_move:
    # Block'ları içerikten kaldır
    for block in blocks_to_move:
        content = content.replace(block, '')
    
    # Block'ları dosyanın en başına ekle
    content = '\n'.join(blocks_to_move) + '\n\n' + content
    
    print(f"{len(blocks_to_move)} server block en başa taşındı")
else:
    print("Server block'lar bulunamadı, yeniden oluşturuluyor...")
    
    # Yeni block'lar oluştur
    new_blocks = f'''
# dugunkarem.com HTTP -> HTTPS redirect
server {{
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com www.dugunkarem.com;
    return 301 https://dugunkarem.com$request_uri;
}}

# dugunkarem.com.tr HTTP -> HTTPS redirect
server {{
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com.tr www.dugunkarem.com.tr;
    return 301 https://dugunkarem.com.tr$request_uri;
}}

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
'''
    content = new_blocks + '\n' + content
    print("4 server block oluşturuldu ve en başa eklendi")

# Tüm proxy_pass'leri port 3040'a çevir
content = re.sub(
    r'proxy_pass\s+http://127\.0\.0\.1:3001',
    f'proxy_pass http://127.0.0.1:{target_port}',
    content
)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("Config güncellendi")
PYEOF

# 8. Nginx test ve reload
echo ""
echo -e "${YELLOW}8️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx restart ediliyor...${NC}"
    sudo systemctl restart nginx
    echo -e "${GREEN}✅ Nginx restart edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    sudo nginx -t
    exit 1
fi

# 9. Test
echo ""
echo -e "${YELLOW}9️⃣ Domain testleri:${NC}"
sleep 2
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

