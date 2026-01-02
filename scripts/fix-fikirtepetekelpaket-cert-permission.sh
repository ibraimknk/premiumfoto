#!/bin/bash

# fikirtepetekelpaket.com sertifika izin sorununu çöz

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 fikirtepetekelpaket.com sertifika izin sorunu çözülüyor...${NC}"

# 1. Sertifika dosyalarının varlığını kontrol et
CERT_DIR="/etc/letsencrypt/live/fikirtepetekelpaket.com"
if [ ! -d "$CERT_DIR" ]; then
    echo -e "${RED}❌ Sertifika dizini bulunamadı: $CERT_DIR${NC}"
    echo -e "${YELLOW}💡 Bu domain için sertifika yok, config'ten kaldırılmalı${NC}"
    exit 1
fi

# 2. Sertifika dosyalarının izinlerini kontrol et
echo -e "${YELLOW}📋 Sertifika izinleri kontrol ediliyor...${NC}"
ls -la "$CERT_DIR" || {
    echo -e "${RED}❌ Sertifika dizinine erişilemiyor${NC}"
    exit 1
}

# 3. Nginx config dosyalarında fikirtepetekelpaket.com sertifikası kullanımını bul
echo -e "${YELLOW}🔍 Nginx config'lerinde fikirtepetekelpaket.com sertifikası aranıyor...${NC}"

# Tüm Nginx config dosyalarını kontrol et
NGINX_CONFIGS=$(find /etc/nginx/sites-available -type f 2>/dev/null || echo "")

if [ -z "$NGINX_CONFIGS" ]; then
    echo -e "${YELLOW}⚠️  Nginx config dosyaları bulunamadı${NC}"
else
    for config in $NGINX_CONFIGS; do
        if grep -q "fikirtepetekelpaket.com" "$config"; then
            echo -e "${YELLOW}📝 Bulundu: $config${NC}"
            echo -e "${YELLOW}   İçerik:${NC}"
            grep -n "fikirtepetekelpaket.com" "$config" | head -5
        fi
    done
fi

# 4. Sertifika izinlerini düzelt (root olarak çalıştırılmalı)
echo -e "${YELLOW}🔧 Sertifika izinleri düzeltiliyor...${NC}"

# Let's Encrypt dizinlerinin izinlerini kontrol et
if [ -d "/etc/letsencrypt/live" ]; then
    # Sertifika dosyalarının okunabilir olduğundan emin ol
    chmod 644 "$CERT_DIR"/*.pem 2>/dev/null || true
    chmod 755 "$CERT_DIR" 2>/dev/null || true
    
    # Nginx'in okuyabilmesi için
    chmod 755 /etc/letsencrypt/live 2>/dev/null || true
    chmod 755 /etc/letsencrypt 2>/dev/null || true
    
    echo -e "${GREEN}✅ Sertifika izinleri düzeltildi${NC}"
else
    echo -e "${RED}❌ /etc/letsencrypt/live dizini bulunamadı${NC}"
fi

# 5. Alternatif: Eğer sertifika yoksa, config'ten kaldır
echo -e "${YELLOW}💡 Eğer sertifika gerçekten yoksa, config'ten kaldırılmalı${NC}"
echo -e "${YELLOW}   Şu komutla kontrol edin:${NC}"
echo "   ls -la /etc/letsencrypt/live/fikirtepetekelpaket.com/"

echo ""
echo -e "${GREEN}✅ İşlem tamamlandı${NC}"
echo ""
echo -e "${YELLOW}📋 Sonraki adımlar:${NC}"
echo "   1. Sertifika var mı kontrol et: ls -la /etc/letsencrypt/live/fikirtepetekelpaket.com/"
echo "   2. Eğer yoksa, config'ten kaldır veya yeni sertifika oluştur"
echo "   3. Nginx test: nginx -t"
echo "   4. Nginx reload: systemctl reload nginx"

