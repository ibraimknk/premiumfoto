#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr için yönlendirme döngüsü düzeltme (Güvenli versiyon)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_FILE="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🔧 dugunkarem.com yönlendirme döngüsü düzeltiliyor (Güvenli versiyon)...${NC}"
echo ""

# Yedek al
echo -e "${YELLOW}📋 Yedek alınıyor...${NC}"
sudo cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo -e "${GREEN}✅ Yedek alındı: ${BACKUP_FILE}${NC}"
echo ""

# Önce mevcut config'deki hatayı kontrol et
echo -e "${YELLOW}🔍 Mevcut config kontrol ediliyor...${NC}"
if sudo nginx -t 2>&1 | grep -q "location directive is not allowed"; then
    echo -e "${YELLOW}⚠️  Config'de zaten hata var, düzeltiliyor...${NC}"
    
    # Hatalı satırı bul ve düzelt
    sudo python3 << PYEOF
import re
import sys

config_file = "${NGINX_CONFIG}"

try:
    with open(config_file, 'r') as f:
        lines = f.readlines()
    
    # Location direktiflerini kontrol et - server bloğu dışında olanları bul
    in_server_block = False
    brace_count = 0
    fixed_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        
        # Server bloğu başlangıcı
        if re.match(r'^\s*server\s*\{', stripped):
            in_server_block = True
            brace_count = stripped.count('{') - stripped.count('}')
            fixed_lines.append(line)
            i += 1
            continue
        
        # Brace sayısını güncelle
        if in_server_block:
            brace_count += stripped.count('{') - stripped.count('}')
            
            # Server bloğu bitti
            if brace_count <= 0:
                in_server_block = False
                brace_count = 0
        
        # Location direktifi server bloğu dışındaysa, kaldır
        if not in_server_block and re.match(r'^\s*location\s+', stripped):
            print(f"⚠️  Satır {i+1}: Location direktifi server bloğu dışında, kaldırılıyor: {stripped[:50]}")
            i += 1
            continue
        
        fixed_lines.append(line)
        i += 1
    
    # Config'i kaydet
    with open(config_file, 'w') as f:
        f.writelines(fixed_lines)
    
    print("✅ Hatalı location direktifleri kaldırıldı")
    
except Exception as e:
    print(f"❌ Hata: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
PYEOF
    echo ""
fi

# Şimdi dugunkarem block'larını temizle ve yeniden ekle
echo -e "${YELLOW}🔧 dugunkarem block'ları temizleniyor ve yeniden ekleniyor...${NC}"
sudo python3 << PYEOF
import re
import sys

config_file = "${NGINX_CONFIG}"

def parse_nginx_blocks(content):
    """Nginx config'deki server block'larını parse et"""
    blocks = []
    i = 0
    while i < len(content):
        # 'server' kelimesini bul
        if content[i:i+6] == 'server':
            # '{' bul
            j = i + 6
            while j < len(content) and content[j] in ' \t\n{':
                if content[j] == '{':
                    start = i
                    # Eşleşen '}' bul
                    depth = 1
                    k = j + 1
                    while k < len(content) and depth > 0:
                        if content[k] == '{':
                            depth += 1
                        elif content[k] == '}':
                            depth -= 1
                        k += 1
                    end = k
                    blocks.append((start, end, content[start:end]))
                    i = end
                    break
                j += 1
        i += 1
    return blocks

try:
    with open(config_file, 'r') as f:
        content = f.read()
    
    # Server block'larını parse et
    blocks = parse_nginx_blocks(content)
    
    # dugunkarem block'larını bul ve kaldır
    domains = ["dugunkarem.com", "dugunkarem.com.tr"]
    blocks_to_remove = []
    
    for start, end, block_content in blocks:
        # dugunkarem domain'i içeriyor mu?
        if any(re.search(rf'\b{re.escape(domain)}\b', block_content, re.IGNORECASE) for domain in domains):
            blocks_to_remove.append((start, end))
            print(f"✅ dugunkarem server block bulundu (satır ~{content[:start].count(chr(10))+1})")
    
    # Block'ları sondan başa doğru kaldır
    for start, end in reversed(blocks_to_remove):
        content = content[:start] + content[end:]
    
    # Tekrarlanan boş satırları temizle
    content = re.sub(r'\n{3,}', '\n\n', content)
    
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
    echo -e "${YELLOW}📋 Hata detayları:${NC}"
    sudo nginx -t 2>&1 | head -20
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
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L --max-redirs 5 "https://dugunkarem.com" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ https://dugunkarem.com çalışıyor (HTTP ${HTTP_CODE})${NC}"
else
    echo -e "${YELLOW}⚠️  https://dugunkarem.com (HTTP ${HTTP_CODE})${NC}"
fi

echo ""
echo -e "${BLUE}dugunkarem.com.tr test:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L --max-redirs 5 "https://dugunkarem.com.tr" || echo "000")
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

