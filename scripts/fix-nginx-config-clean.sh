#!/bin/bash

# Nginx config'i temizleyip düzelten script
# Kullanım: bash scripts/fix-nginx-config-clean.sh

echo "🔧 Nginx config temizleniyor ve düzeltiliyor..."
echo ""

# Nginx config dosyası
NGINX_CONFIG="/etc/nginx/sites-available/foto-ugur"
BACKUP_CONFIG="${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

# Backup oluştur
echo "1️⃣ Config yedekleniyor..."
sudo cp "$NGINX_CONFIG" "$BACKUP_CONFIG"
echo "   ✅ Yedek: $BACKUP_CONFIG"

# Eski location satırlarını temizle
echo ""
echo "2️⃣ Eski location satırları temizleniyor..."

# Tüm location /uploads satırlarını ve sonraki 10 satırı yorum satırı yap
sudo sed -i '/^[[:space:]]*# OLD location \/uploads/,/^[[:space:]]*}/d' "$NGINX_CONFIG"
sudo sed -i '/^[[:space:]]*location \/uploads/,/^[[:space:]]*}/d' "$NGINX_CONFIG"

echo "   ✅ Eski satırlar temizlendi"

# Yeni location ekle (location / satırından önce)
echo ""
echo "3️⃣ Yeni location ekleniyor..."

# location / satırını bul ve öncesine ekle
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

echo "   ✅ Yeni location eklendi"

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
    echo ""
    echo "   Manuel düzenleme gerekli:"
    echo "   sudo nano $NGINX_CONFIG"
    exit 1
fi

echo ""
echo "✅ İşlem tamamlandı!"

