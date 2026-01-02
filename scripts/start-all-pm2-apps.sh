#!/bin/bash

# Tüm PM2 uygulamalarını kontrol et ve başlat

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Tüm PM2 uygulamaları kontrol ediliyor ve başlatılıyor...${NC}"

# 1. Mevcut PM2 durumu
echo -e "${YELLOW}📊 Mevcut PM2 durumu:${NC}"
pm2 status

# 2. Her uygulamayı kontrol et ve başlat
APPS=(
    "foto-ugur-app:/home/ibrahim/premiumfoto:npm start"
    "dugunkarem-app:/home/ibrahim/dugunkarem:npm start"
    "oxeliodigital:/home/ibrahim/oxeliodigital:npm start"
)

for app_config in "${APPS[@]}"; do
    IFS=':' read -r app_name app_dir app_cmd <<< "$app_config"
    
    echo ""
    echo -e "${YELLOW}🔍 $app_name kontrol ediliyor...${NC}"
    
    # PM2'de var mı kontrol et
    if pm2 list | grep -q "$app_name"; then
        STATUS=$(pm2 jlist | jq -r ".[] | select(.name==\"$app_name\") | .pm2_env.status" 2>/dev/null || echo "unknown")
        
        if [ "$STATUS" = "online" ]; then
            echo -e "${GREEN}✅ $app_name zaten çalışıyor${NC}"
        elif [ "$STATUS" = "stopped" ] || [ "$STATUS" = "errored" ]; then
            echo -e "${YELLOW}⚠️  $app_name durdurulmuş, başlatılıyor...${NC}"
            pm2 restart "$app_name" --update-env || pm2 start "$app_name" --update-env
            sleep 2
        else
            echo -e "${YELLOW}⚠️  $app_name durumu: $STATUS, yeniden başlatılıyor...${NC}"
            pm2 restart "$app_name" --update-env
            sleep 2
        fi
    else
        # PM2'de yok, başlat
        echo -e "${YELLOW}🚀 $app_name PM2'de yok, başlatılıyor...${NC}"
        
        if [ ! -d "$app_dir" ]; then
            echo -e "${RED}❌ Dizin bulunamadı: $app_dir${NC}"
            continue
        fi
        
        cd "$app_dir"
        
        # Ecosystem config var mı kontrol et
        if [ -f "ecosystem.config.js" ] || [ -f "ecosystem.config.cjs" ]; then
            CONFIG_FILE=$(ls ecosystem.config.* 2>/dev/null | head -1)
            pm2 start "$CONFIG_FILE"
        else
            # Direkt npm start ile başlat
            pm2 start npm --name "$app_name" -- start
        fi
        
        sleep 2
    fi
done

# 3. PM2'ye kaydet
echo ""
echo -e "${YELLOW}💾 PM2'ye kaydediliyor...${NC}"
pm2 save

# 4. Son durum
echo ""
echo -e "${YELLOW}📊 Son PM2 durumu:${NC}"
pm2 status

# 5. Port kontrolü
echo ""
echo -e "${YELLOW}🔍 Port durumları:${NC}"
PORTS=(3040 3000 3001)
for port in "${PORTS[@]}"; do
    echo "Port $port:"
    sudo lsof -i:$port | head -2 || echo "  Boş"
done

echo ""
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"
echo ""
echo -e "${YELLOW}📋 Yönetim komutları:${NC}"
echo "   pm2 status"
echo "   pm2 logs [app-name]"
echo "   pm2 restart [app-name]"
echo "   pm2 stop [app-name]"

