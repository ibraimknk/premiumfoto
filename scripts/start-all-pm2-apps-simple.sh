#!/bin/bash

# Tüm PM2 uygulamalarını başlat (basit versiyon)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Tüm PM2 uygulamaları başlatılıyor...${NC}"

# 1. foto-ugur-app
echo -e "${YELLOW}🔍 foto-ugur-app kontrol ediliyor...${NC}"
if pm2 list | grep -q "foto-ugur-app"; then
    STATUS=$(pm2 jlist | jq -r '.[] | select(.name=="foto-ugur-app") | .pm2_env.status' 2>/dev/null || echo "unknown")
    if [ "$STATUS" != "online" ]; then
        echo -e "${YELLOW}⚠️  foto-ugur-app durdurulmuş, başlatılıyor...${NC}"
        pm2 restart foto-ugur-app --update-env
    else
        echo -e "${GREEN}✅ foto-ugur-app zaten çalışıyor${NC}"
    fi
else
    echo -e "${YELLOW}🚀 foto-ugur-app başlatılıyor...${NC}"
    cd ~/premiumfoto
    pm2 start npm --name "foto-ugur-app" -- start
fi

# 2. dugunkarem-app
echo -e "${YELLOW}🔍 dugunkarem-app kontrol ediliyor...${NC}"
if pm2 list | grep -q "dugunkarem-app"; then
    STATUS=$(pm2 jlist | jq -r '.[] | select(.name=="dugunkarem-app") | .pm2_env.status' 2>/dev/null || echo "unknown")
    if [ "$STATUS" != "online" ]; then
        echo -e "${YELLOW}⚠️  dugunkarem-app durdurulmuş, başlatılıyor...${NC}"
        pm2 restart dugunkarem-app --update-env
    else
        echo -e "${GREEN}✅ dugunkarem-app zaten çalışıyor${NC}"
    fi
else
    echo -e "${YELLOW}🚀 dugunkarem-app başlatılıyor...${NC}"
    if [ -d ~/dugunkarem ]; then
        cd ~/dugunkarem
        if [ -f "ecosystem.config.js" ] || [ -f "ecosystem.config.cjs" ]; then
            CONFIG_FILE=$(ls ecosystem.config.* 2>/dev/null | head -1)
            pm2 start "$CONFIG_FILE"
        else
            pm2 start npm --name "dugunkarem-app" -- start
        fi
    else
        echo -e "${RED}❌ dugunkarem dizini bulunamadı: ~/dugunkarem${NC}"
    fi
fi

# 3. oxeliodigital
echo -e "${YELLOW}🔍 oxeliodigital kontrol ediliyor...${NC}"
if pm2 list | grep -q "oxeliodigital"; then
    STATUS=$(pm2 jlist | jq -r '.[] | select(.name=="oxeliodigital") | .pm2_env.status' 2>/dev/null || echo "unknown")
    if [ "$STATUS" != "online" ]; then
        echo -e "${YELLOW}⚠️  oxeliodigital durdurulmuş, başlatılıyor...${NC}"
        pm2 restart oxeliodigital --update-env
    else
        echo -e "${GREEN}✅ oxeliodigital zaten çalışıyor${NC}"
    fi
else
    echo -e "${YELLOW}🚀 oxeliodigital başlatılıyor...${NC}"
    if [ -d ~/oxeliodigital ]; then
        cd ~/oxeliodigital
        if [ -f "ecosystem.config.js" ] || [ -f "ecosystem.config.cjs" ]; then
            CONFIG_FILE=$(ls ecosystem.config.* 2>/dev/null | head -1)
            pm2 start "$CONFIG_FILE"
        else
            pm2 start npm --name "oxeliodigital" -- start
        fi
    else
        echo -e "${RED}❌ oxeliodigital dizini bulunamadı: ~/oxeliodigital${NC}"
    fi
fi

# 4. PM2'ye kaydet
echo ""
echo -e "${YELLOW}💾 PM2'ye kaydediliyor...${NC}"
pm2 save

# 5. Son durum
echo ""
echo -e "${YELLOW}📊 Son PM2 durumu:${NC}"
pm2 status

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"

