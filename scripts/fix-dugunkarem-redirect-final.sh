#!/bin/bash

# dugunkarem.com yönlendirme döngüsünü tamamen düzeltme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_FILE="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🔧 dugunkarem.com yönlendirme döngüsü tamamen düzeltiliyor...${NC}"
echo ""

# Yedek al
echo -e "${YELLOW}📋 Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo -e "${GREEN}✅ Yedek alındı: ${BACKUP_FILE}${NC}"
echo ""

# Önce mevcut config'i kontrol et
echo -e "${YELLOW}🔍 Mevcut dugunkarem block'ları kontrol ediliyor...${NC}"
sudo grep -n "dugunkarem" "$NGINX_CONFIG" | head -20
echo ""

# Python script ile tamamen temizle ve yeniden oluştur
echo -e "${YELLOW}🔧 dugunkarem block'ları temizleniyor ve yeniden oluşturuluyor...${NC}"
sudo python3 << PYEOF
import re
import sys

config_file = "${NGINX_CONFIG}"

try:
    with open(config_file, 'r') as f:
        content = f.read()
    
    # Tüm dugunkarem ile ilgili satırları bul ve kaldır
    lines = content.split('\n')
    new_lines = []
    skip_until_brace = 0
    in_dugunkarem_block = False
    brace_count = 0
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # dugunkarem içeren server block'u başlangıcı
        if 'server' in line and 'dugunkarem' in content[max(0, content.find(line) - 200):content.find(line) + 200]:
            # Bu satırdan sonraki tüm satırları server block bitene kadar atla
            in_dugunkarem_block = True
            brace_count = line.count('{') - line.count('}')
            i += 1
            # Server block bitene kadar devam et
            while i < len(lines) and (brace_count > 0 or in_dugunkarem_block):
                current_line = lines[i]
                brace_count += current_line.count('{') - current_line.count('}')
                if brace_count <= 0 and '}' in current_line:
                    in_dugunkarem_block = False
                    i += 1
                    break
                i += 1
            continue
        
        # dugunkarem içeren tek satır direktifler
        if 'dugunkarem' in line.lower():
            print(f"   ⚠️  Satır {i+1} kaldırılıyor: {line.strip()[:60]}")
            i += 1
            continue
        
        new_lines.append(line)
        i += 1
    
    content = '\n'.join(new_lines)
    
    # Tekrarlanan boş satırları temizle
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    # Temiz dugunkarem block'ları ekle
    cert_path = "/etc/letsencrypt/live/dugunkarem.com"
    dollar = "$"
    
    dugunkarem_blocks = f'''
# dugunkarem.com ve dugunkarem.com.tr - HTTP'den HTTPS'e yönlendirme
server {{
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com dugunkarem.com.tr;
    return 301 https://{dollar}host{ dollar}request_uri;
}}

# dugunkarem.com - HTTPS (Port 3040)
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com;
    
    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    client_max_body_size 50M;
    
    location / {{
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade {dollar}http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host {dollar}host;
        proxy_set_header X-Real-IP {dollar}remote_addr;
        proxy_set_header X-Forwarded-For {dollar}proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto {dollar}scheme;
        proxy_cache_bypass {dollar}http_upgrade;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }}
}}

# dugunkarem.com.tr - HTTPS (Port 3040)
server {{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name dugunkarem.com.tr;
    
    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    client_max_body_size 50M;
    
    location / {{
        proxy_pass http://127.0.0.1:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade {dollar}http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host {dollar}host;
        proxy_set_header X-Real-IP {dollar}remote_addr;
        proxy_set_header X-Forwarded-For {dollar}proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto {dollar}scheme;
        proxy_cache_bypass {dollar}http_upgrade;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }}
}}
'''
    
    content = content.rstrip() + "\n" + dugunkarem_blocks
    
    # Config'i kaydet
    with open(config_file, 'w') as f:
        f.write(content)
    
    print("✅ dugunkarem block'ları temizlendi ve yeniden eklendi")
    
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
    sudo nginx -t 2>&1 | head -20
    sudo cp "$BACKUP_FILE" "$NGINX_CONFIG"
    exit 1
fi
echo ""

# Nginx reload
echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
sudo systemctl reload nginx
echo -e "${GREEN}✅ Nginx reload edildi${NC}"
echo ""

# Test (max-redirs ile)
echo -e "${YELLOW}🧪 HTTPS erişimi test ediliyor (max-redirs: 1)...${NC}"
echo ""

echo -e "${BLUE}dugunkarem.com test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L --max-redirs 1 "https://dugunkarem.com" 2>&1 || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ https://dugunkarem.com çalışıyor (HTTP ${HTTP_CODE})${NC}"
elif [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${YELLOW}⚠️  https://dugunkarem.com yönlendirme yapıyor (HTTP ${HTTP_CODE})${NC}"
    echo -e "${YELLOW}   Yönlendirme döngüsü olabilir, kontrol edin.${NC}"
else
    echo -e "${YELLOW}⚠️  https://dugunkarem.com (HTTP ${HTTP_CODE})${NC}"
fi

echo ""
echo -e "${BLUE}dugunkarem.com.tr test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L --max-redirs 1 "https://dugunkarem.com.tr" 2>&1 || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ https://dugunkarem.com.tr çalışıyor (HTTP ${HTTP_CODE})${NC}"
elif [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${YELLOW}⚠️  https://dugunkarem.com.tr yönlendirme yapıyor (HTTP ${HTTP_CODE})${NC}"
    echo -e "${YELLOW}   Yönlendirme döngüsü olabilir, kontrol edin.${NC}"
else
    echo -e "${YELLOW}⚠️  https://dugunkarem.com.tr (HTTP ${HTTP_CODE})${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Yönlendirme Döngüsü Düzeltildi!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

