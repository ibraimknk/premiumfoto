#!/bin/bash

# dugunkarem.com sertifikasını manuel olarak yükle

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CERT_NAME="dugunkarem.com"
DOMAIN="dugunkarem.com.tr"
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"
CERT_PATH="/etc/letsencrypt/live/${CERT_NAME}"

echo -e "${YELLOW}🔧 ${CERT_NAME} sertifikası manuel olarak yükleniyor...${NC}"

# 1. Sertifika var mı kontrol et
echo -e "${YELLOW}🔍 Sertifika aranıyor...${NC}"

# Önce dugunkarem.com dizinini kontrol et
if [ -d "${CERT_PATH}" ]; then
    echo -e "${GREEN}✅ Sertifika dizini mevcut: ${CERT_PATH}${NC}"
    
    # Dosyaları listele
    echo -e "${YELLOW}📋 Dizin içeriği:${NC}"
    sudo ls -la "${CERT_PATH}" || true
    
    # fullchain.pem var mı?
    if [ ! -f "${CERT_PATH}/fullchain.pem" ]; then
        echo -e "${YELLOW}⚠️  fullchain.pem bulunamadı, archive dizininden kontrol ediliyor...${NC}"
        
        # Archive dizininden kontrol et
        ARCHIVE_DIR="/etc/letsencrypt/archive/${CERT_NAME}"
        if [ -d "$ARCHIVE_DIR" ]; then
            echo -e "${GREEN}✅ Archive dizini mevcut: $ARCHIVE_DIR${NC}"
            LATEST_CERT=$(sudo ls -t "$ARCHIVE_DIR"/fullchain*.pem 2>/dev/null | head -1)
            if [ -n "$LATEST_CERT" ]; then
                echo -e "${GREEN}✅ Sertifika bulundu: $LATEST_CERT${NC}"
                # Symlink oluştur
                sudo ln -sf "$LATEST_CERT" "${CERT_PATH}/fullchain.pem" 2>/dev/null || true
                sudo ln -sf "$(sudo ls -t "$ARCHIVE_DIR"/privkey*.pem 2>/dev/null | head -1)" "${CERT_PATH}/privkey.pem" 2>/dev/null || true
                sudo ln -sf "$(sudo ls -t "$ARCHIVE_DIR"/chain*.pem 2>/dev/null | head -1)" "${CERT_PATH}/chain.pem" 2>/dev/null || true
            fi
        fi
    fi
else
    echo -e "${RED}❌ Sertifika dizini bulunamadı: ${CERT_PATH}${NC}"
    echo -e "${YELLOW}💡 Mevcut sertifikalar:${NC}"
    sudo ls -la /etc/letsencrypt/live/ || true
    exit 1
fi

# Son kontrol (symlink'ler için -L kullan)
if [ ! -L "${CERT_PATH}/fullchain.pem" ] && [ ! -f "${CERT_PATH}/fullchain.pem" ]; then
    echo -e "${RED}❌ Sertifika dosyası bulunamadı: ${CERT_PATH}/fullchain.pem${NC}"
    echo -e "${YELLOW}💡 Sertifika oluşturulmalı:${NC}"
    echo "   sudo certbot certonly --nginx -d dugunkarem.com -d dugunkarem.com.tr"
    exit 1
fi

# Symlink'in geçerli olduğunu kontrol et
if [ -L "${CERT_PATH}/fullchain.pem" ]; then
    TARGET=$(sudo readlink -f "${CERT_PATH}/fullchain.pem")
    if [ -f "$TARGET" ]; then
        echo -e "${GREEN}✅ Sertifika mevcut (symlink): ${CERT_PATH}/fullchain.pem -> $TARGET${NC}"
    else
        echo -e "${RED}❌ Symlink geçersiz: ${CERT_PATH}/fullchain.pem -> $TARGET${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Sertifika mevcut: ${CERT_PATH}/fullchain.pem${NC}"
fi

# 2. certbot install deneyelim
echo -e "${YELLOW}📝 Certbot install deneniyor...${NC}"
sudo certbot install --cert-name ${CERT_NAME} --nginx 2>&1 || {
    echo -e "${YELLOW}⚠️  Certbot install başarısız, manuel yükleme yapılıyor...${NC}"
}

# 3. Config'te dugunkarem.com.tr için SSL server block'unu bul ve sertifika path'lerini düzelt
echo -e "${YELLOW}📝 Config dosyası düzeltiliyor...${NC}"

sudo python3 << PYEOF
import re

config_file = "${FOTO_UGUR_CONFIG}"

with open(config_file, 'r') as f:
    content = f.read()

# dugunkarem.com.tr içeren SSL server block'unu bul
pattern = r'(server\s*\{[^}]*listen\s+443[^}]*server_name[^}]*dugunkarem\.com\.tr[^}]*)(.*?)(\})'

def fix_ssl_cert(match):
    block_start = match.group(1)
    block_content = match.group(2)
    block_end = match.group(3)
    
    # SSL sertifika path'lerini düzelt
    cert_path = "${CERT_PATH}"
    
    # Mevcut ssl_certificate satırlarını değiştir
    block_start = re.sub(r'ssl_certificate\s+[^;]+;', f'ssl_certificate {cert_path}/fullchain.pem;', block_start)
    block_start = re.sub(r'ssl_certificate_key\s+[^;]+;', f'ssl_certificate_key {cert_path}/privkey.pem;', block_start)
    
    # Eğer ssl_certificate yoksa ekle
    if 'ssl_certificate' not in block_start:
        ssl_config = f'''
    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
'''
        block_start = block_start.rstrip() + ssl_config
    
    # return 404 satırlarını kaldır
    block_content = re.sub(r'\s*return\s+404[^;]*;', '', block_content)
    block_content = re.sub(r'\s*#\s*managed by Certbot', '', block_content)
    
    # proxy_pass var mı kontrol et
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

content = re.sub(pattern, fix_ssl_cert, content, flags=re.DOTALL)

# Çoklu boş satırları temizle
content = re.sub(r'\n\n\n+', '\n\n', content)

with open(config_file, 'w') as f:
    f.write(content)

print("✅ Config düzeltildi")
PYEOF

# 4. Nginx test ve reload
echo -e "${YELLOW}🔄 Nginx test ediliyor...${NC}"
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    echo -e "${YELLOW}💡 Config dosyasını kontrol edin:${NC}"
    echo "   sudo nano $FOTO_UGUR_CONFIG"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Sertifika manuel olarak yüklendi!${NC}"
echo ""
echo -e "${YELLOW}📋 Test:${NC}"
echo "   curl -I https://${DOMAIN}"
echo "   openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} < /dev/null 2>/dev/null | openssl x509 -noout -subject"

