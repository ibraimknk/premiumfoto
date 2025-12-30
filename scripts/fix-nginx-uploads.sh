#!/bin/bash

# Nginx uploads yapılandırmasını düzelten script
# Kullanım: bash scripts/fix-nginx-uploads.sh

echo "🔧 Nginx uploads yapılandırması düzeltiliyor..."
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
CURRENT_CONFIG=$(sudo cat "$NGINX_CONFIG" | grep -A 5 "location /uploads")

if echo "$CURRENT_CONFIG" | grep -q "alias.*premiumfoto"; then
    echo "   ✅ Path doğru görünüyor"
else
    echo "   ⚠️ Path kontrol edilmeli"
fi

# Config'i güncelle
echo ""
echo "3️⃣ Config güncelleniyor..."

# Hem /uploads hem de /uploads/ için location ekle
sudo tee -a /tmp/nginx-uploads-fix.txt > /dev/null << 'EOF'
    # Uploads için statik dosya servisi - hem /uploads hem /uploads/ için
    location ~ ^/uploads(/.*)?$ {
        alias /home/ibrahim/premiumfoto/public/uploads$1;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
        
        # Dosya bulunamazsa 404 döndür
        try_files $uri =404;
        
        # İzin kontrolü
        disable_symlinks off;
    }
EOF

echo "   ✅ Config hazırlandı"
echo ""
echo "📋 Manuel düzenleme gerekiyor:"
echo "   sudo nano $NGINX_CONFIG"
echo ""
echo "   Şu satırları bulun:"
echo "   location /uploads {"
echo "   veya"
echo "   location /uploads/ {"
echo ""
echo "   Şöyle değiştirin:"
echo "   location ~ ^/uploads(/.*)?$ {"
echo "       alias /home/ibrahim/premiumfoto/public/uploads\$1;"
echo "       expires 30d;"
echo "       add_header Cache-Control \"public, immutable\";"
echo "       access_log off;"
echo "       try_files \$uri =404;"
echo "       disable_symlinks off;"
echo "   }"
echo ""
echo "   VEYA daha basit:"
echo "   location /uploads/ {"
echo "       alias /home/ibrahim/premiumfoto/public/uploads/;"
echo "       expires 30d;"
echo "       add_header Cache-Control \"public, immutable\";"
echo "       try_files \$uri =404;"
echo "   }"
echo ""
echo "4️⃣ Nginx test ve reload:"
echo "   sudo nginx -t"
echo "   sudo systemctl reload nginx"

