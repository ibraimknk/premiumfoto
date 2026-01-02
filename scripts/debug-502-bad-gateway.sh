#!/bin/bash

# 502 Bad Gateway hatasını debug et

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_PORT=3040
APP_NAME="foto-ugur-app"
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo -e "${BLUE}🔍 502 Bad Gateway Debug Raporu${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 1. Port 3040 kontrolü
echo -e "${YELLOW}1️⃣ Port ${APP_PORT} kontrolü:${NC}"
if sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Port ${APP_PORT} dinleniyor${NC}"
    echo -e "${YELLOW}📋 Process detayları:${NC}"
    sudo lsof -i:${APP_PORT}
else
    echo -e "${RED}❌ Port ${APP_PORT} dinlenmiyor!${NC}"
    echo -e "${YELLOW}💡 foto-ugur-app çalışmıyor olabilir${NC}"
fi
echo ""

# 2. PM2 durumu
echo -e "${YELLOW}2️⃣ PM2 durumu:${NC}"
if pm2 list | grep -q "${APP_NAME}"; then
    STATUS=$(pm2 jlist | jq -r ".[] | select(.name==\"${APP_NAME}\") | .pm2_env.status" 2>/dev/null || echo "unknown")
    RESTARTS=$(pm2 jlist | jq -r ".[] | select(.name==\"${APP_NAME}\") | .pm2_env.restart_time" 2>/dev/null || echo "0")
    if [ "$STATUS" = "online" ]; then
        echo -e "${GREEN}✅ ${APP_NAME} çalışıyor (restart: $RESTARTS)${NC}"
    else
        echo -e "${RED}❌ ${APP_NAME} durumu: $STATUS (restart: $RESTARTS)${NC}"
    fi
    pm2 list | grep "${APP_NAME}"
else
    echo -e "${RED}❌ ${APP_NAME} PM2'de bulunamadı!${NC}"
fi
echo ""

# 3. Localhost test
echo -e "${YELLOW}3️⃣ Localhost test (http://localhost:${APP_PORT}):${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT} 2>&1 || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ Localhost çalışıyor! (HTTP $HTTP_CODE)${NC}"
    curl -I http://localhost:${APP_PORT} 2>&1 | head -5
else
    echo -e "${RED}❌ Localhost yanıt vermiyor! (HTTP $HTTP_CODE)${NC}"
    if [ "$HTTP_CODE" = "000" ]; then
        echo -e "${YELLOW}💡 Bağlantı hatası - uygulama çalışmıyor olabilir${NC}"
    fi
fi
echo ""

# 4. Nginx config kontrolü
echo -e "${YELLOW}4️⃣ Nginx config kontrolü:${NC}"
if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
else
    echo -e "${GREEN}✅ Config dosyası mevcut${NC}"
    
    # dugunkarem.com için proxy_pass kontrolü
    echo -e "${YELLOW}📋 dugunkarem.com proxy_pass:${NC}"
    if sudo grep -A 10 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | grep -q "proxy_pass.*127.0.0.1:${APP_PORT}"; then
        echo -e "${GREEN}✅ Port ${APP_PORT}'a yönlendiriliyor${NC}"
        sudo grep -A 10 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | grep "proxy_pass" | head -1
    else
        echo -e "${RED}❌ Port ${APP_PORT}'a yönlendirilmiyor!${NC}"
        echo -e "${YELLOW}📋 Mevcut proxy_pass:${NC}"
        sudo grep -A 10 "server_name.*dugunkarem.com" "$NGINX_CONFIG" | grep "proxy_pass" | head -1 || echo "proxy_pass bulunamadı"
    fi
    
    # dugunkarem.com.tr için proxy_pass kontrolü
    echo -e "${YELLOW}📋 dugunkarem.com.tr proxy_pass:${NC}"
    if sudo grep -A 10 "server_name.*dugunkarem.com.tr" "$NGINX_CONFIG" | grep -q "proxy_pass.*127.0.0.1:${APP_PORT}"; then
        echo -e "${GREEN}✅ Port ${APP_PORT}'a yönlendiriliyor${NC}"
        sudo grep -A 10 "server_name.*dugunkarem.com.tr" "$NGINX_CONFIG" | grep "proxy_pass" | head -1
    else
        echo -e "${RED}❌ Port ${APP_PORT}'a yönlendirilmiyor!${NC}"
        echo -e "${YELLOW}📋 Mevcut proxy_pass:${NC}"
        sudo grep -A 10 "server_name.*dugunkarem.com.tr" "$NGINX_CONFIG" | grep "proxy_pass" | head -1 || echo "proxy_pass bulunamadı"
    fi
    
    # fotougur.com.tr için proxy_pass kontrolü
    echo -e "${YELLOW}📋 fotougur.com.tr proxy_pass:${NC}"
    if sudo grep -A 10 "server_name.*fotougur.com.tr" "$NGINX_CONFIG" | grep -q "proxy_pass.*127.0.0.1:${APP_PORT}"; then
        echo -e "${GREEN}✅ Port ${APP_PORT}'a yönlendiriliyor${NC}"
        sudo grep -A 10 "server_name.*fotougur.com.tr" "$NGINX_CONFIG" | grep "proxy_pass" | head -1
    else
        echo -e "${RED}❌ Port ${APP_PORT}'a yönlendirilmiyor!${NC}"
        echo -e "${YELLOW}📋 Mevcut proxy_pass:${NC}"
        sudo grep -A 10 "server_name.*fotougur.com.tr" "$NGINX_CONFIG" | grep "proxy_pass" | head -1 || echo "proxy_pass bulunamadı"
    fi
fi
echo ""

# 5. Nginx error log
echo -e "${YELLOW}5️⃣ Nginx error log (son 20 satır):${NC}"
if [ -f "/var/log/nginx/error.log" ]; then
    ERROR_COUNT=$(sudo tail -20 /var/log/nginx/error.log | grep -c "502\|Bad Gateway\|Connection refused" || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}⚠️  ${ERROR_COUNT} hata bulundu${NC}"
        sudo tail -20 /var/log/nginx/error.log | grep -E "502|Bad Gateway|Connection refused" | tail -5
    else
        echo -e "${GREEN}✅ Son 20 satırda 502 hatası yok${NC}"
    fi
    echo -e "${YELLOW}📋 Son 5 satır:${NC}"
    sudo tail -5 /var/log/nginx/error.log
else
    echo -e "${RED}❌ Error log bulunamadı${NC}"
fi
echo ""

# 6. PM2 logları (son hatalar)
echo -e "${YELLOW}6️⃣ PM2 error log (son 10 satır):${NC}"
if pm2 list | grep -q "${APP_NAME}"; then
    ERROR_COUNT=$(pm2 logs "${APP_NAME}" --err --lines 50 --nostream 2>/dev/null | grep -c -i "error\|failed\|eaddrinuse" || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}⚠️  ${ERROR_COUNT} hata bulundu${NC}"
        pm2 logs "${APP_NAME}" --err --lines 10 --nostream 2>/dev/null | tail -5
    else
        echo -e "${GREEN}✅ Son loglarda hata yok${NC}"
    fi
else
    echo -e "${RED}❌ ${APP_NAME} PM2'de bulunamadı${NC}"
fi
echo ""

# 7. Özet ve öneriler
echo -e "${BLUE}📊 Özet:${NC}"
echo -e "${BLUE}================================${NC}"

ISSUES=0

# Port kontrolü
if ! sudo lsof -i:${APP_PORT} > /dev/null 2>&1; then
    echo -e "${RED}❌ Port ${APP_PORT} dinlenmiyor${NC}"
    ISSUES=$((ISSUES + 1))
fi

# PM2 kontrolü
if ! pm2 list | grep -q "${APP_NAME}.*online"; then
    echo -e "${RED}❌ ${APP_NAME} çalışmıyor${NC}"
    ISSUES=$((ISSUES + 1))
fi

# Localhost test
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT} 2>&1 || echo "000")
if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "301" ] && [ "$HTTP_CODE" != "302" ]; then
    echo -e "${RED}❌ Localhost yanıt vermiyor (HTTP $HTTP_CODE)${NC}"
    ISSUES=$((ISSUES + 1))
fi

if [ "$ISSUES" -eq 0 ]; then
    echo -e "${GREEN}✅ Tüm kontroller başarılı!${NC}"
    echo -e "${YELLOW}💡 Sorun Nginx config'inde olabilir, fix-502-bad-gateway-complete.sh scriptini çalıştırın${NC}"
else
    echo -e "${RED}❌ $ISSUES sorun bulundu${NC}"
    echo -e "${YELLOW}💡 fix-502-bad-gateway-complete.sh scriptini çalıştırın${NC}"
fi

echo ""
echo -e "${YELLOW}📋 Önerilen komutlar:${NC}"
echo "   bash scripts/fix-502-bad-gateway-complete.sh"
echo "   pm2 restart ${APP_NAME} --update-env"
echo "   sudo systemctl reload nginx"

