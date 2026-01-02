#!/bin/bash

# Nginx config'deki tüm hataları düzeltme ve dugunkarem block'larını ekleme

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_FILE="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🔧 Nginx config tamamen düzeltiliyor...${NC}"
echo ""

# Yedek al
echo -e "${YELLOW}📋 Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo -e "${GREEN}✅ Yedek alındı: ${BACKUP_FILE}${NC}"
echo ""

# Python script ile tüm hataları düzelt
echo -e "${YELLOW}🔧 Tüm hatalar düzeltiliyor...${NC}"
sudo python3 << PYEOF
import re
import sys

config_file = "${NGINX_CONFIG}"

def parse_nginx_blocks(content):
    """Nginx config'deki server block'larını parse et"""
    blocks = []
    i = 0
    while i < len(content):
        if content[i:i+6] == 'server':
            j = i + 6
            while j < len(content) and content[j] in ' \t\n{':
                if content[j] == '{':
                    start = i
                    depth = 1
                    k = j + 1
                    while k < len(content) and depth > 0:
                        if content[k] == '{':
                            depth += 1
                        elif content[k] == '}':
                            depth -= 1
                        k += 1
                    end = k
                    blocks.append((start, end))
                    i = end
                    break
                j += 1
        i += 1
    return blocks

try:
    with open(config_file, 'r') as f:
        content = f.read()
    
    # 1. Önce tüm proxy_set_header hatalarını düzelt
    print("1️⃣ proxy_set_header hataları kontrol ediliyor...")
    
    # Eksik $ karakterlerini ekle
    content = re.sub(r'proxy_set_header\s+Host\s+host\s*;', 'proxy_set_header Host $host;', content, flags=re.IGNORECASE)
    content = re.sub(r'proxy_set_header\s+X-Real-IP\s+remote_addr\s*;', 'proxy_set_header X-Real-IP $remote_addr;', content, flags=re.IGNORECASE)
    content = re.sub(r'proxy_set_header\s+X-Forwarded-For\s+proxy_add_x_forwarded_for\s*;', 'proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;', content, flags=re.IGNORECASE)
    content = re.sub(r'proxy_set_header\s+X-Forwarded-Proto\s+scheme\s*;', 'proxy_set_header X-Forwarded-Proto $scheme;', content, flags=re.IGNORECASE)
    content = re.sub(r'proxy_set_header\s+Upgrade\s+http_upgrade\s*;', 'proxy_set_header Upgrade $http_upgrade;', content, flags=re.IGNORECASE)
    
    # Eksik argümanlı proxy_set_header satırlarını kaldır
    lines = content.split('\n')
    fixed_lines = []
    for i, line in enumerate(lines):
        # Eğer sadece "proxy_set_header" varsa ve değer yoksa, kaldır
        if re.match(r'^\s*proxy_set_header\s*$', line):
            print(f"   ⚠️  Satır {i+1}: Eksik proxy_set_header satırı kaldırılıyor")
            continue
        # Eğer proxy_set_header var ama sadece 1 argüman varsa, kaldır
        parts = line.split()
        if len(parts) == 2 and 'proxy_set_header' in parts[0]:
            print(f"   ⚠️  Satır {i+1}: Eksik argümanlı proxy_set_header kaldırılıyor: {line.strip()}")
            continue
        fixed_lines.append(line)
    content = '\n'.join(fixed_lines)
    
    print("   ✅ proxy_set_header hataları düzeltildi")
    
    # 2. dugunkarem block'larını kaldır
    print("2️⃣ dugunkarem block'ları kaldırılıyor...")
    blocks = parse_nginx_blocks(content)
    domains = ["dugunkarem.com", "dugunkarem.com.tr"]
    blocks_to_remove = []
    
    for start, end in blocks:
        block_content = content[start:end]
        if any(re.search(rf'\b{re.escape(domain)}\b', block_content, re.IGNORECASE) for domain in domains):
            blocks_to_remove.append((start, end))
    
    for start, end in reversed(blocks_to_remove):
        content = content[:start] + content[end:]
    
    print(f"   ✅ {len(blocks_to_remove)} dugunkarem block kaldırıldı")
    
    # 3. Temiz dugunkarem block'ları ekle
    print("3️⃣ Temiz dugunkarem block'ları ekleniyor...")
    cert_path = "/etc/letsencrypt/live/dugunkarem.com"
    dollar = "$"
    
    dugunkarem_blocks = f'''
# dugunkarem.com ve dugunkarem.com.tr - HTTP'den HTTPS'e yönlendirme
server {{
    listen 80;
    listen [::]:80;
    server_name dugunkarem.com dugunkarem.com.tr;
    return 301 https://{dollar}host{dollar}request_uri;
}}

# dugunkarem.com - HTTPS
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

# dugunkarem.com.tr - HTTPS
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
    print("   ✅ dugunkarem block'ları eklendi")
    
    # 4. Tekrarlanan boş satırları temizle
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    # Config'i kaydet
    with open(config_file, 'w') as f:
        f.write(content)
    
    print("✅ Nginx config tamamen düzeltildi")
    
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
    sudo nginx -t 2>&1 | head -30
    echo ""
    echo -e "${YELLOW}💡 Hatalı satırları kontrol edin:${NC}"
    ERROR_LINE=$(sudo nginx -t 2>&1 | grep -oP 'line \K\d+' | head -1)
    if [ ! -z "$ERROR_LINE" ]; then
        START_LINE=$((ERROR_LINE - 2))
        END_LINE=$((ERROR_LINE + 2))
        echo -e "${BLUE}Satır ${START_LINE}-${END_LINE}:${NC}"
        sudo sed -n "${START_LINE},${END_LINE}p" "$NGINX_CONFIG"
    fi
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

# Test
echo -e "${YELLOW}🧪 HTTPS erişimi test ediliyor...${NC}"
echo ""

echo -e "${BLUE}dugunkarem.com test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L --max-redirs 2 "https://dugunkarem.com" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ https://dugunkarem.com çalışıyor (HTTP ${HTTP_CODE})${NC}"
else
    echo -e "${YELLOW}⚠️  https://dugunkarem.com (HTTP ${HTTP_CODE})${NC}"
fi

echo ""
echo -e "${BLUE}dugunkarem.com.tr test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L --max-redirs 2 "https://dugunkarem.com.tr" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ https://dugunkarem.com.tr çalışıyor (HTTP ${HTTP_CODE})${NC}"
else
    echo -e "${YELLOW}⚠️  https://dugunkarem.com.tr (HTTP ${HTTP_CODE})${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Nginx Config Tamamen Düzeltildi!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

