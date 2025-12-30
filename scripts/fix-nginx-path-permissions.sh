#!/bin/bash

# Nginx path izinlerini düzelten script
# Nginx'in dosyaya erişebilmesi için tüm üst klasörlerde execute izni olmalı
# Kullanım: bash scripts/fix-nginx-path-permissions.sh

echo "🔧 Nginx path izinleri düzeltiliyor..."
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Nginx kullanıcısı
NGINX_USER="www-data"

# Uploads klasörü
UPLOADS_DIR="public/uploads"
FULL_PATH=$(realpath "$UPLOADS_DIR")

echo "📋 Uploads klasörü: $FULL_PATH"
echo ""

# Tüm üst klasörlere execute izni ver
echo "1️⃣ Üst klasör izinleri düzeltiliyor..."

# home/ibrahim
if [ -d "/home/ibrahim" ]; then
    sudo chmod 755 /home/ibrahim
    echo "   ✅ /home/ibrahim: 755"
fi

# premiumfoto
if [ -d "/home/ibrahim/premiumfoto" ]; then
    sudo chmod 755 /home/ibrahim/premiumfoto
    echo "   ✅ /home/ibrahim/premiumfoto: 755"
fi

# public
if [ -d "/home/ibrahim/premiumfoto/public" ]; then
    sudo chmod 755 /home/ibrahim/premiumfoto/public
    echo "   ✅ /home/ibrahim/premiumfoto/public: 755"
fi

# uploads
if [ -d "/home/ibrahim/premiumfoto/public/uploads" ]; then
    sudo chmod 755 /home/ibrahim/premiumfoto/public/uploads
    echo "   ✅ /home/ibrahim/premiumfoto/public/uploads: 755"
fi

# Nginx kullanıcısına sahiplik ver (tüm üst klasörler)
echo ""
echo "2️⃣ Nginx kullanıcısına sahiplik veriliyor..."

# Sadece uploads klasörüne sahiplik ver (üst klasörlere gerek yok)
sudo chown -R "$NGINX_USER:$NGINX_USER" "$UPLOADS_DIR"
echo "   ✅ $UPLOADS_DIR: $NGINX_USER:$NGINX_USER"

# Alternatif: Üst klasörlere de grup ekle (daha güvenli)
echo ""
echo "3️⃣ Grup izinleri düzeltiliyor..."

# www-data grubunu ibrahim kullanıcısına ekle (opsiyonel)
# sudo usermod -a -G ibrahim www-data

# Üst klasörlere grup okuma izni ver
sudo chmod g+rx /home/ibrahim 2>/dev/null || true
sudo chmod g+rx /home/ibrahim/premiumfoto 2>/dev/null || true
sudo chmod g+rx /home/ibrahim/premiumfoto/public 2>/dev/null || true
echo "   ✅ Grup izinleri eklendi"

# Dosya izinleri
echo ""
echo "4️⃣ Dosya izinleri düzeltiliyor..."
find "$UPLOADS_DIR" -type f -exec chmod 644 {} \; 2>/dev/null
find "$UPLOADS_DIR" -type d -exec chmod 755 {} \; 2>/dev/null
echo "   ✅ Dosya izinleri: 644, klasör izinleri: 755"

# İzin kontrolü
echo ""
echo "5️⃣ İzin kontrolü:"
echo "   /home/ibrahim:"
ls -ld /home/ibrahim | awk '{print $1, $3, $4}'
echo "   /home/ibrahim/premiumfoto:"
ls -ld /home/ibrahim/premiumfoto | awk '{print $1, $3, $4}'
echo "   /home/ibrahim/premiumfoto/public:"
ls -ld /home/ibrahim/premiumfoto/public | awk '{print $1, $3, $4}'
echo "   /home/ibrahim/premiumfoto/public/uploads:"
ls -ld /home/ibrahim/premiumfoto/public/uploads | awk '{print $1, $3, $4}'

# Nginx'i restart et (cache temizlemek için)
echo ""
echo "6️⃣ Nginx restart ediliyor (cache temizlemek için)..."
sudo systemctl restart nginx
echo "   ✅ Nginx restart edildi"

echo ""
echo "✅ İşlem tamamlandı!"
echo ""
echo "💡 Test için:"
echo "   npm run test-nginx"

