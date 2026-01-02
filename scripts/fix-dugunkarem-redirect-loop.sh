#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr için yönlendirme döngüsü düzeltme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_FILE="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🔧 dugunkarem.com yönlendirme döngüsü düzeltiliyor...${NC}"
echo ""

# Yedek al
echo -e "${YELLOW}📋 Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo -e "${GREEN}✅ Yedek alındı: ${BACKUP_FILE}${NC}"
echo ""

# Python script ile düzelt
echo -e "${YELLOW}🔧 Nginx config düzeltiliyor...${NC}"
sudo python3 << PYEOF
import re
import sys

config_file = "${NGINX_CONFIG}"

try:
    with open(config_file, 'r') as f:
        content = f.read()
    
    # dugunkarem.com ve dugunkarem.com.tr için tüm server block'ları bul
    domains = ["dugunkarem.com", "dugunkarem.com.tr"]
    
    # Her domain için
    for domain in domains:
        # Domain için tüm server block'ları bul
        pattern = rf'(server\s*{{[^}}]*server_name[^}}]*{re.escape(domain)}[^}}]*}})'
        matches = re.finditer(pattern, content, re.DOTALL | re.IGNORECASE)
        
        blocks_to_remove = []
        for match in matches:
            block = match.group(1)
            # Eğer bu block sadece yönlendirme yapıyorsa ve HTTPS'te ise, kaldır
            if 'return 301' in block or 'return 302' in block:
                # HTTPS'ten HTTPS'e yönlendirme varsa, kaldır
                if 'listen 443' in block or 'ssl' in block:
                    blocks_to_remove.append(block)
                    print(f"✅ {domain} için HTTPS'ten HTTPS'e yönlendirme kaldırılıyor")
        
        # Block'ları kaldır
        for block in blocks_to_remove:
            content = content.replace(block, '')
    
    # Tekrarlanan boş satırları temizle
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    # dugunkarem domain'leri için doğru server block'ları oluştur
    # Önce mevcut dugunkarem block'larını temizle
    for domain in domains:
        # Tüm dugunkarem block'larını bul ve kaldır
        pattern = rf'(server\s*{{[^}}]*server_name[^}}]*{re.escape(domain)}[^}}]*}})'
        content = re.sub(pattern, '', content, flags=re.DOTALL | re.IGNORECASE)
    
    # Temiz dugunkarem block'ları ekle
    cert_path = "/etc/letsencrypt/live/dugunkarem.com"
    
    dugunkarem_blocks = f'''
# dugunkarem.com ve dugunkarem.com.tr - HTTP'den HTTPS'e yönlendirme
server {{
    listen 80;
    server_name dugunkarem.com dugunkarem.com.tr;
    return 301 https://$host$request_uri;
}}

# dugunkarem.com - HTTPS
server {{
    listen 443 ssl http2;
    server_name dugunkarem.com;
    
    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    location / {{
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }}
}}

# dugunkarem.com.tr - HTTPS
server {{
    listen 443 ssl http2;
    server_name dugunkarem.com.tr;
    
    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    location / {{
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }}
}}
'''
    
    # Config'in sonuna ekle
    content = content.rstrip() + "\n" + dugunkarem_blocks
    
    # Config'i kaydet
    with open(config_file, 'w') as f:
        f.write(content)
    
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
    echo -e "${RED}❌ Nginx config hatası! Yedekten geri yükleniyor...${NC}"
    sudo cp "$BACKUP_FILE" "$NGINX_CONFIG"
    exit 1
fi
echo ""

# Nginx reload
echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
sudo systemctl reload nginx
echo -e "${GREEN}✅ Nginx reload edildi${NC}"
echo ""

# Test
echo -e "${YELLOW}🧪 HTTPS erişimi test ediliyor...${NC}"
echo ""

echo -e "${BLUE}dugunkarem.com test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "https://dugunkarem.com" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ https://dugunkarem.com çalışıyor (HTTP ${HTTP_CODE})${NC}"
else
    echo -e "${YELLOW}⚠️  https://dugunkarem.com (HTTP ${HTTP_CODE})${NC}"
fi

echo ""
echo -e "${BLUE}dugunkarem.com.tr test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "https://dugunkarem.com.tr" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ https://dugunkarem.com.tr çalışıyor (HTTP ${HTTP_CODE})${NC}"
else
    echo -e "${YELLOW}⚠️  https://dugunkarem.com.tr (HTTP ${HTTP_CODE})${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Yönlendirme Döngüsü Düzeltildi!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}💡 Tarayıcıda test edin:${NC}"
echo "   https://dugunkarem.com"
echo "   https://dugunkarem.com.tr"
echo ""

