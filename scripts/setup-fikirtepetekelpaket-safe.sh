#!/bin/bash

# fikirtepetekelpaket.com için güvenli Nginx config oluştur (diğer domain'leri bozmadan)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="fikirtepetekelpaket.com"
APP_PORT=3001
CONFIG_FILE="/etc/nginx/sites-available/fikirtepetekelpaket.com"
ENABLED_LINK="/etc/nginx/sites-enabled/fikirtepetekelpaket.com"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔧 ${DOMAIN} için güvenli Nginx config oluşturuluyor...${NC}"
echo ""

# 1. Mevcut foto-ugur config'ini kontrol et
echo -e "${YELLOW}1️⃣ Mevcut foto-ugur config kontrol ediliyor...${NC}"
if [ -f "$FOTO_UGUR_CONFIG" ]; then
    echo -e "${GREEN}✅ foto-ugur config mevcut${NC}"
    # Yedek al
    sudo cp "$FOTO_UGUR_CONFIG" "${FOTO_UGUR_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✅ Yedek alındı${NC}"
    
    # foto-ugur config'inde fikirtepetekelpaket.com var mı kontrol et
    if sudo grep -q "fikirtepetekelpaket.com" "$FOTO_UGUR_CONFIG"; then
        echo -e "${YELLOW}⚠️  foto-ugur config'inde fikirtepetekelpaket.com bulundu, temizleniyor...${NC}"
        sudo python3 << 'PYEOF'
import re

config_file = "/etc/nginx/sites-available/foto-ugur"

with open(config_file, 'r', encoding='utf-8') as f:
    content = f.read()

# fikirtepetekelpaket.com içeren server block'larını kaldır
lines = content.split('\n')
fixed_lines = []
i = 0
in_fikirtepe_block = False
brace_count = 0

while i < len(lines):
    line = lines[i]
    
    if 'server {' in line:
        # Sonraki birkaç satırı kontrol et
        block_start = i
        brace_count = 1
        block_lines = [line]
        j = i + 1
        
        while j < len(lines) and brace_count > 0:
            block_lines.append(lines[j])
            if '{' in lines[j]:
                brace_count += lines[j].count('{')
            if '}' in lines[j]:
                brace_count -= lines[j].count('}')
            j += 1
        
        block_content = ''.join(block_lines)
        
        # Eğer fikirtepetekelpaket.com içeriyorsa ve dugunkarem/fotougur içermiyorsa, atla
        if 'fikirtepetekelpaket.com' in block_content.lower() and 'dugunkarem' not in block_content.lower() and 'fotougur' not in block_content.lower():
            # Bu block'u atla
            i = j
            continue
    
    fixed_lines.append(line)
    i += 1

content = '\n'.join(fixed_lines)

# Boş satırları temizle
lines = content.split('\n')
cleaned_lines = []
prev_empty = False

for line in lines:
    is_empty = line.strip() == ''
    if is_empty and prev_empty:
        continue
    cleaned_lines.append(line)
    prev_empty = is_empty

content = '\n'.join(cleaned_lines)

with open(config_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ foto-ugur config'inden fikirtepetekelpaket.com temizlendi")
PYEOF
        echo -e "${GREEN}✅ Temizlendi${NC}"
    else
        echo -e "${GREEN}✅ foto-ugur config'inde fikirtepetekelpaket.com yok${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  foto-ugur config bulunamadı${NC}"
fi
echo ""

# 2. fikirtepetekelpaket.com için ayrı config oluştur
echo -e "${YELLOW}2️⃣ ${DOMAIN} için ayrı config oluşturuluyor...${NC}"

sudo tee "$CONFIG_FILE" > /dev/null << EOF
# HTTP - HTTPS'e yönlendirme
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    
    # HTTPS'e yönlendir
    return 301 https://\$host\$request_uri;
}

# HTTPS - Port ${APP_PORT}'e proxy
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN} www.${DOMAIN};
    
    # SSL sertifikası
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    
    client_max_body_size 50M;
    
    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeout ayarları
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

echo -e "${GREEN}✅ Config oluşturuldu${NC}"
echo ""

# 3. Config'i aktif et
echo -e "${YELLOW}3️⃣ Config aktif ediliyor...${NC}"
sudo ln -sf "$CONFIG_FILE" "$ENABLED_LINK"
echo -e "${GREEN}✅ Config aktif edildi${NC}"
echo ""

# 4. SSL sertifikası kontrolü
echo -e "${YELLOW}4️⃣ SSL sertifikası kontrol ediliyor...${NC}"
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo -e "${YELLOW}⚠️  SSL sertifikası bulunamadı${NC}"
    echo -e "${YELLOW}💡 SSL sertifikası kurmak için:${NC}"
    echo "   sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --expand"
else
    echo -e "${GREEN}✅ SSL sertifikası mevcut${NC}"
fi
echo ""

# 5. Nginx test
echo -e "${YELLOW}5️⃣ Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}📋 Hata detayları:${NC}"
    sudo nginx -t 2>&1 | head -20
    exit 1
fi
echo ""

# 6. Test
echo -e "${YELLOW}6️⃣ Domain testleri:${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr" "fotougur.com.tr" "fikirtepetekelpaket.com")
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
echo -e "${YELLOW}📋 Özet:${NC}"
echo "   - ${DOMAIN} için ayrı config oluşturuldu: ${CONFIG_FILE}"
echo "   - Config aktif edildi: ${ENABLED_LINK}"
echo "   - Port ${APP_PORT}'e yönlendiriliyor"
echo "   - Diğer domain'ler (dugunkarem.com, dugunkarem.com.tr, fotougur.com.tr) etkilenmedi"

