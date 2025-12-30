#!/bin/bash

# Nginx location /uploads düzeltmesi
# location /uploads/ yerine location /uploads kullan (trailing slash olmadan)
# Kullanım: bash scripts/fix-nginx-location.sh

echo "🔧 Nginx location düzeltiliyor..."
echo ""

# Nginx config dosyası
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_CONFIG="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# Backup oluştur
echo "1️⃣ Config yedekleniyor..."
sudo cp "$NGINX_CONFIG" "$BACKUP_CONFIG"
echo "   ✅ Yedek: $BACKUP_CONFIG"

# Mevcut location'ı kontrol et
echo ""
echo "2️⃣ Mevcut location kontrol ediliyor..."
sudo grep -A 5 "location /uploads" "$NGINX_CONFIG"

# location /uploads/ yerine location /uploads yap
echo ""
echo "3️⃣ Location düzeltiliyor..."

# location /uploads/ satırını location /uploads yap
sudo sed -i 's|location /uploads/ {|location /uploads {|g' "$NGINX_CONFIG"

# alias path'inden trailing slash'i kaldır
sudo sed -i 's|alias /home/ibrahim/premiumfoto/public/uploads/;|alias /home/ibrahim/premiumfoto/public/uploads;|g' "$NGINX_CONFIG"

echo "   ✅ Location düzeltildi"

# Config'i göster
echo ""
echo "4️⃣ Yeni config:"
sudo grep -A 6 "location /uploads" "$NGINX_CONFIG"

# Nginx test
echo ""
echo "5️⃣ Nginx config test ediliyor..."
if sudo nginx -t 2>&1 | grep -q "successful"; then
    echo "   ✅ Config geçerli"
    
    # Nginx reload
    echo ""
    echo "6️⃣ Nginx reload ediliyor..."
    sudo systemctl reload nginx
    echo "   ✅ Nginx reload edildi"
else
    echo "   ❌ Config hatası!"
    sudo nginx -t
    exit 1
fi

echo ""
echo "✅ İşlem tamamlandı!"

