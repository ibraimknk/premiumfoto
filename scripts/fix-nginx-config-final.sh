#!/bin/bash

# Nginx config'i kesin çözümle düzelten script
# Kullanım: bash scripts/fix-nginx-config-final.sh

echo "🔧 Nginx config kesin çözümle düzeltiliyor..."
echo ""

# Nginx config dosyası
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_CONFIG="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# Backup oluştur
echo "1️⃣ Config yedekleniyor..."
sudo cp "$NGINX_CONFIG" "$BACKUP_CONFIG"
echo "   ✅ Yedek: $BACKUP_CONFIG"

# Mevcut config'i kontrol et
echo ""
echo "2️⃣ Mevcut config kontrol ediliyor..."
sudo cat "$NGINX_CONFIG" | grep -A 5 "location /uploads"

# Config'i düzelt
echo ""
echo "3️⃣ Config düzeltiliyor..."

# Önce mevcut location /uploads satırlarını yorum satırı yap
sudo sed -i 's|^[[:space:]]*location /uploads|    # OLD location /uploads|g' "$NGINX_CONFIG"

# Yeni location ekle (location / ile başlayan satırdan önce)
sudo sed -i '/^[[:space:]]*location \/ {/i\
    # Uploads için statik dosya servisi\
    location /uploads/ {\
        alias /home/ibrahim/premiumfoto/public/uploads/;\
        expires 30d;\
        add_header Cache-Control "public, immutable";\
        access_log off;\
        try_files $uri =404;\
    }\
' "$NGINX_CONFIG"

echo "   ✅ Config güncellendi"

# Nginx test
echo ""
echo "4️⃣ Nginx config test ediliyor..."
if sudo nginx -t; then
    echo "   ✅ Config geçerli"
    
    # Nginx reload
    echo ""
    echo "5️⃣ Nginx reload ediliyor..."
    sudo systemctl reload nginx
    echo "   ✅ Nginx reload edildi"
else
    echo "   ❌ Config hatası! Manuel düzenleme gerekli."
    echo ""
    echo "   sudo nano $NGINX_CONFIG"
    exit 1
fi

# Test
echo ""
echo "6️⃣ Test ediliyor..."
sleep 2
TEST_FILE="instagram-dugunkaremcom-1767121928499-gvlrlg-2019-05-25_15-15-54_UTC.jpg"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/uploads/$TEST_FILE")

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Dosya erişilebilir! (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" = "404" ]; then
    echo "   ❌ Hala 404 - Error log kontrol edin:"
    echo "   sudo tail -20 /var/log/nginx/error.log"
else
    echo "   ⚠️ HTTP $HTTP_CODE"
fi

echo ""
echo "✅ İşlem tamamlandı!"

