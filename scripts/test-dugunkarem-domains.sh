#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr domain testleri

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 dugunkarem.com ve dugunkarem.com.tr test ediliyor...${NC}"
echo ""

# 1. Nginx config kontrolü
echo -e "${YELLOW}1️⃣ Nginx config kontrolü:${NC}"
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
if sudo grep -q "server_name.*dugunkarem.com" "$NGINX_CONFIG"; then
    echo -e "${GREEN}✅ dugunkarem.com server block bulundu${NC}"
    echo -e "${YELLOW}   Server block'lar:${NC}"
    sudo grep -A 2 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | head -10
else
    echo -e "${RED}❌ dugunkarem.com server block bulunamadı!${NC}"
fi
echo ""

# 2. Port 3040 kontrolü
echo -e "${YELLOW}2️⃣ Port 3040 kontrolü:${NC}"
if curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:3040 | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ Port 3040 çalışıyor${NC}"
    curl -I http://localhost:3040 2>/dev/null | head -3
else
    echo -e "${RED}❌ Port 3040 çalışmıyor!${NC}"
fi
echo ""

# 3. HTTP testleri (port 80)
echo -e "${YELLOW}3️⃣ HTTP testleri (port 80):${NC}"
DOMAINS=("dugunkarem.com" "dugunkarem.com.tr")
for domain in "${DOMAINS[@]}"; do
    echo -e "${YELLOW}   Test ediliyor: http://${domain}${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://${domain} 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}   ✅ ${domain}: HTTP ${HTTP_CODE}${NC}"
    else
        echo -e "${RED}   ❌ ${domain}: HTTP ${HTTP_CODE}${NC}"
    fi
done
echo ""

# 4. HTTPS testleri (port 443)
echo -e "${YELLOW}4️⃣ HTTPS testleri (port 443):${NC}"
for domain in "${DOMAINS[@]}"; do
    echo -e "${YELLOW}   Test ediliyor: https://${domain}${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 -k https://${domain} 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}   ✅ ${domain}: HTTPS ${HTTP_CODE}${NC}"
    else
        echo -e "${RED}   ❌ ${domain}: HTTPS ${HTTP_CODE}${NC}"
        # SSL hatası detayı
        curl -v https://${domain} 2>&1 | grep -i "ssl\|certificate\|error" | head -3 || true
    fi
done
echo ""

# 5. Nginx error log kontrolü
echo -e "${YELLOW}5️⃣ Nginx error log (son 10 satır):${NC}"
sudo tail -10 /var/log/nginx/error.log 2>/dev/null | grep -i "dugunkarem\|3040\|error" || echo "   Hata log'unda dugunkarem ile ilgili kayıt yok"
echo ""

# 6. Nginx access log kontrolü
echo -e "${YELLOW}6️⃣ Nginx access log (son 5 satır):${NC}"
sudo tail -5 /var/log/nginx/access.log 2>/dev/null | grep -i "dugunkarem" || echo "   Access log'unda dugunkarem ile ilgili kayıt yok"
echo ""

# 7. DNS kontrolü
echo -e "${YELLOW}7️⃣ DNS kontrolü:${NC}"
for domain in "${DOMAINS[@]}"; do
    echo -e "${YELLOW}   ${domain}:${NC}"
    nslookup ${domain} 2>/dev/null | grep -A 2 "Name:" || echo "   DNS kaydı bulunamadı"
done
echo ""

# 8. Özet
echo -e "${BLUE}📊 Özet:${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "${YELLOW}💡 Eğer domain'ler çalışmıyorsa:${NC}"
echo "   1. DNS kayıtlarını kontrol edin"
echo "   2. SSL sertifikalarını kontrol edin: sudo certbot certificates"
echo "   3. Nginx config'i kontrol edin: sudo nginx -t"
echo "   4. Nginx'i restart edin: sudo systemctl restart nginx"
echo ""
echo -e "${YELLOW}💡 Manuel test:${NC}"
echo "   curl -I http://dugunkarem.com"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I http://dugunkarem.com.tr"
echo "   curl -I https://dugunkarem.com.tr"

