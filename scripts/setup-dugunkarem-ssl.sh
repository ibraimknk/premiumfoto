#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr için SSL sertifikası kurulumu

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAINS=("dugunkarem.com" "dugunkarem.com.tr")
EMAIL="info@fotougur.com.tr"
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔒 dugunkarem.com ve dugunkarem.com.tr için SSL Kurulumu${NC}"
echo ""

# 1. Certbot kurulumu kontrolü
echo -e "${YELLOW}1️⃣ Certbot kontrol ediliyor...${NC}"
if ! command -v certbot &> /dev/null; then
    echo -e "${YELLOW}📦 Certbot kuruluyor...${NC}"
    sudo apt update
    sudo apt install -y certbot python3-certbot-nginx
    echo -e "${GREEN}✅ Certbot kuruldu${NC}"
else
    echo -e "${GREEN}✅ Certbot zaten kurulu${NC}"
fi
echo ""

# 2. Nginx config yedeği
echo -e "${YELLOW}2️⃣ Nginx config yedeği alınıyor...${NC}"
BACKUP_FILE="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
sudo cp "$NGINX_CONFIG" "$BACKUP_FILE" 2>/dev/null || true
echo -e "${GREEN}✅ Yedek alındı: ${BACKUP_FILE}${NC}"
echo ""

# 3. Domain'lerin erişilebilirliğini kontrol et
echo -e "${YELLOW}3️⃣ Domain'lerin erişilebilirliği kontrol ediliyor...${NC}"
for domain in "${DOMAINS[@]}"; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://${domain}" || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}✅ ${domain} erişilebilir (HTTP ${HTTP_CODE})${NC}"
    else
        echo -e "${RED}❌ ${domain} erişilemiyor (HTTP ${HTTP_CODE})${NC}"
        echo -e "${YELLOW}⚠️  DNS kayıtlarını kontrol edin${NC}"
    fi
done
echo ""

# 4. SSL sertifikası al
echo -e "${YELLOW}4️⃣ SSL sertifikası alınıyor...${NC}"
echo -e "${BLUE}   Domain'ler: ${DOMAINS[*]}${NC}"
echo ""

# Certbot ile SSL sertifikası al (standalone mod - Nginx çalışırken)
sudo certbot certonly --nginx \
    -d "${DOMAINS[0]}" \
    -d "${DOMAINS[1]}" \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    --preferred-challenges http \
    || {
    echo -e "${YELLOW}⚠️  Certbot --nginx başarısız, standalone mod deneniyor...${NC}"
    # Nginx'i geçici olarak durdur
    sudo systemctl stop nginx
    
    # Standalone mod ile sertifika al
    sudo certbot certonly --standalone \
        -d "${DOMAINS[0]}" \
        -d "${DOMAINS[1]}" \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        --preferred-challenges http
    
    # Nginx'i tekrar başlat
    sudo systemctl start nginx
}

if [ -f "/etc/letsencrypt/live/${DOMAINS[0]}/fullchain.pem" ]; then
    echo -e "${GREEN}✅ SSL sertifikası başarıyla alındı${NC}"
else
    echo -e "${RED}❌ SSL sertifikası alınamadı!${NC}"
    exit 1
fi
echo ""

# 5. Nginx config'e SSL ekle
echo -e "${YELLOW}5️⃣ Nginx config'e SSL yapılandırması ekleniyor...${NC}"

CERT_PATH="/etc/letsencrypt/live/${DOMAINS[0]}"

# Python script ile Nginx config'i güncelle
sudo python3 << PYEOF
import re
import sys

config_file = "${NGINX_CONFIG}"
cert_path = "${CERT_PATH}"

try:
    with open(config_file, 'r') as f:
        content = f.read()
    
    # dugunkarem domain'leri için server block'ları bul
    domains = ["dugunkarem.com", "dugunkarem.com.tr"]
    
    # Her domain için HTTPS server block'u ekle
    for domain in domains:
        # Domain için mevcut HTTP server block'u bul
        pattern = rf'(server\s*{{[^}}]*server_name\s+{re.escape(domain)}[^}}]*}})'
        match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
        
        if match:
            http_block = match.group(1)
            
            # Eğer zaten SSL yapılandırması varsa, atla
            if 'ssl_certificate' in http_block:
                print(f"✅ {domain} için SSL zaten yapılandırılmış")
                continue
            
            # HTTPS server block oluştur
            https_block = http_block.replace('listen 80;', f'''listen 443 ssl http2;
    ssl_certificate {cert_path}/fullchain.pem;
    ssl_certificate_key {cert_path}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;''')
            
            # HTTP'den HTTPS'e yönlendirme ekle
            redirect_block = f'''server {{
    listen 80;
    server_name {domain};
    return 301 https://$host$request_uri;
}}'''
            
            # HTTP block'u redirect block ile değiştir ve HTTPS block'u ekle
            content = content.replace(http_block, redirect_block + "\n\n" + https_block)
            print(f"✅ {domain} için SSL yapılandırması eklendi")
        else:
            # Domain için server block yoksa, yeni oluştur
            new_blocks = f'''
# HTTP - HTTPS'e yönlendirme
server {{
    listen 80;
    server_name {domain};
    return 301 https://$host$request_uri;
}}

# HTTPS - Port 3040'e proxy
server {{
    listen 443 ssl http2;
    server_name {domain};
    
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
    }}
}}
'''
            content += new_blocks
            print(f"✅ {domain} için yeni server block oluşturuldu")
    
    # Config'i kaydet
    with open(config_file, 'w') as f:
        f.write(content)
    
    print("✅ Nginx config güncellendi")
    
except Exception as e:
    print(f"❌ Hata: {e}")
    sys.exit(1)
PYEOF

echo ""

# 6. Nginx test
echo -e "${YELLOW}6️⃣ Nginx config test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
else
    echo -e "${RED}❌ Nginx config hatası! Yedekten geri yükleniyor...${NC}"
    sudo cp "$BACKUP_FILE" "$NGINX_CONFIG"
    exit 1
fi
echo ""

# 7. Nginx reload
echo -e "${YELLOW}7️⃣ Nginx reload ediliyor...${NC}"
sudo systemctl reload nginx
echo -e "${GREEN}✅ Nginx reload edildi${NC}"
echo ""

# 8. SSL sertifikası kontrolü
echo -e "${YELLOW}8️⃣ SSL sertifikası kontrol ediliyor...${NC}"
sudo certbot certificates
echo ""

# 9. Test
echo -e "${YELLOW}9️⃣ HTTPS erişimi test ediliyor...${NC}"
for domain in "${DOMAINS[@]}"; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://${domain}" || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}✅ https://${domain} erişilebilir (HTTP ${HTTP_CODE})${NC}"
    else
        echo -e "${YELLOW}⚠️  https://${domain} henüz erişilemiyor (HTTP ${HTTP_CODE})${NC}"
        echo -e "${YELLOW}💡 Birkaç dakika bekleyip tekrar deneyin${NC}"
    fi
done
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ SSL Kurulumu Tamamlandı!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 Yapılan İşlemler:${NC}"
echo "   1. ✅ Certbot kuruldu/kontrol edildi"
echo "   2. ✅ SSL sertifikası alındı"
echo "   3. ✅ Nginx config güncellendi"
echo "   4. ✅ Nginx reload edildi"
echo ""
echo -e "${YELLOW}🔍 Test Komutları:${NC}"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"
echo "   sudo certbot certificates"
echo ""
echo -e "${YELLOW}💡 Otomatik Yenileme:${NC}"
echo "   Certbot otomatik olarak sertifikaları yeniler (90 günde bir)"
echo "   Manuel yenileme için: sudo certbot renew"
echo ""
