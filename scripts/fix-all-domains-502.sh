#!/bin/bash

# Tüm domain'lerin 502 hatasını düzelt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Tüm domain'lerin 502 hatası düzeltiliyor...${NC}"

# 1. PM2 durumunu kontrol et
echo -e "${YELLOW}📊 PM2 durumu kontrol ediliyor...${NC}"
pm2 status

# 2. Port kullanımlarını kontrol et
echo -e "${YELLOW}🔍 Port kullanımları kontrol ediliyor...${NC}"
echo -e "${YELLOW}Port 3040 (foto-ugur-app):${NC}"
sudo lsof -i:3040 | head -3 || echo "Port 3040 boş"
echo ""
echo -e "${YELLOW}Port 3001 (aktas-market):${NC}"
sudo lsof -i:3001 | head -3 || echo "Port 3001 boş"
echo ""

# 3. Nginx config'i kontrol et
echo -e "${YELLOW}📝 Nginx config kontrol ediliyor...${NC}"
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"

if [ ! -f "$NGINX_CONFIG" ]; then
    echo -e "${RED}❌ Nginx config bulunamadı: $NGINX_CONFIG${NC}"
    exit 1
fi

# dugunkarem.com ve dugunkarem.com.tr için proxy_pass kontrolü
echo -e "${YELLOW}🔍 dugunkarem.com ve dugunkarem.com.tr proxy_pass kontrolü...${NC}"
if grep -q "dugunkarem.com" "$NGINX_CONFIG"; then
    grep -A 5 "dugunkarem.com" "$NGINX_CONFIG" | grep -A 3 "proxy_pass" || echo "proxy_pass bulunamadı"
else
    echo -e "${RED}❌ dugunkarem.com Nginx config'de bulunamadı!${NC}"
fi

# fikirtepetekelpaket.com için proxy_pass kontrolü
echo -e "${YELLOW}🔍 fikirtepetekelpaket.com proxy_pass kontrolü...${NC}"
if grep -q "fikirtepetekelpaket.com" "$NGINX_CONFIG"; then
    grep -A 5 "fikirtepetekelpaket.com" "$NGINX_CONFIG" | grep -A 3 "proxy_pass" || echo "proxy_pass bulunamadı"
else
    echo -e "${YELLOW}⚠️  fikirtepetekelpaket.com Nginx config'de bulunamadı, ayrı config olabilir${NC}"
    # Ayrı config dosyası var mı kontrol et
    if [ -f "/etc/nginx/sites-available/fikirtepetekelpaket" ]; then
        echo -e "${GREEN}✅ Ayrı config bulundu: /etc/nginx/sites-available/fikirtepetekelpaket${NC}"
        grep -A 5 "server_name" "/etc/nginx/sites-available/fikirtepetekelpaket" | grep -A 3 "proxy_pass" || echo "proxy_pass bulunamadı"
    fi
fi

# 4. PM2 uygulamalarını kontrol et ve gerekirse başlat
echo ""
echo -e "${YELLOW}🔄 PM2 uygulamaları kontrol ediliyor...${NC}"

# foto-ugur-app (port 3040)
if pm2 list | grep -q "foto-ugur-app"; then
    STATUS=$(pm2 jlist | jq -r '.[] | select(.name=="foto-ugur-app") | .pm2_env.status' 2>/dev/null || echo "unknown")
    if [ "$STATUS" != "online" ]; then
        echo -e "${YELLOW}⚠️  foto-ugur-app çalışmıyor, başlatılıyor...${NC}"
        pm2 restart foto-ugur-app --update-env
    else
        echo -e "${GREEN}✅ foto-ugur-app çalışıyor${NC}"
    fi
else
    echo -e "${RED}❌ foto-ugur-app PM2'de bulunamadı!${NC}"
    echo -e "${YELLOW}💡 Başlatmak için: cd ~/premiumfoto && pm2 start npm --name foto-ugur-app -- start${NC}"
fi

# aktas-market (port 3001)
if pm2 list | grep -q "aktas-market"; then
    STATUS=$(pm2 jlist | jq -r '.[] | select(.name=="aktas-market") | .pm2_env.status' 2>/dev/null || echo "unknown")
    if [ "$STATUS" != "online" ]; then
        echo -e "${YELLOW}⚠️  aktas-market çalışmıyor, başlatılıyor...${NC}"
        if [ -f "/var/www/fikirtepetekelpaket.com/ecosystem-aktas-market.config.cjs" ]; then
            pm2 start /var/www/fikirtepetekelpaket.com/ecosystem-aktas-market.config.cjs
        else
            echo -e "${RED}❌ ecosystem config bulunamadı!${NC}"
        fi
    else
        echo -e "${GREEN}✅ aktas-market çalışıyor${NC}"
    fi
else
    echo -e "${RED}❌ aktas-market PM2'de bulunamadı!${NC}"
    if [ -f "/var/www/fikirtepetekelpaket.com/ecosystem-aktas-market.config.cjs" ]; then
        echo -e "${YELLOW}💡 Başlatılıyor...${NC}"
        pm2 start /var/www/fikirtepetekelpaket.com/ecosystem-aktas-market.config.cjs
    fi
fi

# 5. Nginx config'ini test et ve reload et
echo ""
echo -e "${YELLOW}🔄 Nginx config test ediliyor...${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✅ Nginx config geçerli${NC}"
    echo -e "${YELLOW}🔄 Nginx reload ediliyor...${NC}"
    sudo systemctl reload nginx
    echo -e "${GREEN}✅ Nginx reload edildi${NC}"
else
    echo -e "${RED}❌ Nginx config hatası!${NC}"
    exit 1
fi

# 6. Son durum kontrolü
echo ""
echo -e "${YELLOW}📊 Son durum kontrolü...${NC}"
pm2 status
echo ""
echo -e "${YELLOW}🔍 Port durumları:${NC}"
echo "Port 3040:"
sudo lsof -i:3040 | head -2 || echo "  Boş"
echo "Port 3001:"
sudo lsof -i:3001 | head -2 || echo "  Boş"

echo ""
echo -e "${GREEN}✅ İşlemler tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Test komutları:${NC}"
echo "   curl -I http://localhost:3040"
echo "   curl -I http://localhost:3001"
echo "   pm2 logs foto-ugur-app --lines 20"
echo "   pm2 logs aktas-market --lines 20"

