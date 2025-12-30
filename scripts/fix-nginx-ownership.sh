#!/bin/bash

# Nginx sahiplik sorununu düzelten script
# Kullanım: bash scripts/fix-nginx-ownership.sh

echo "🔧 Nginx sahiplik sorunu düzeltiliyor..."
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Nginx worker process kullanıcısını bul
echo "1️⃣ Nginx worker process kullanıcısı kontrol ediliyor..."
NGINX_WORKER=$(ps aux | grep "nginx: worker process" | head -1 | awk '{print $1}')

if [ -z "$NGINX_WORKER" ]; then
    # Nginx config'den kontrol et
    NGINX_USER=$(sudo grep -E "^user " /etc/nginx/nginx.conf | awk '{print $2}' | tr -d ';')
    if [ -z "$NGINX_USER" ]; then
        # Varsayılan olarak www-data dene
        if id "www-data" &>/dev/null; then
            NGINX_USER="www-data"
        else
            echo "❌ Nginx kullanıcısı bulunamadı!"
            exit 1
        fi
    fi
else
    NGINX_USER="$NGINX_WORKER"
fi

echo "   📋 Nginx worker kullanıcısı: $NGINX_USER"
echo ""

# Uploads klasörü
UPLOADS_DIR="public/uploads"

# İzinleri düzelt
echo "2️⃣ İzinler düzeltiliyor..."

# Klasör izinleri: 755
chmod 755 "$UPLOADS_DIR"
echo "   ✅ Klasör izinleri: 755"

# Dosyalar için: 644
find "$UPLOADS_DIR" -type f -exec chmod 644 {} \; 2>/dev/null
echo "   ✅ Dosya izinleri: 644"

# Klasörler için: 755
find "$UPLOADS_DIR" -type d -exec chmod 755 {} \; 2>/dev/null
echo "   ✅ Alt klasör izinleri: 755"

# Üst klasörlere de erişim izni ver
chmod 755 public 2>/dev/null
chmod 755 "$(pwd)" 2>/dev/null
echo "   ✅ Üst klasör izinleri: 755"

# Nginx kullanıcısına sahiplik ver
echo ""
echo "3️⃣ Nginx kullanıcısına sahiplik veriliyor..."
sudo chown -R "$NGINX_USER:$NGINX_USER" "$UPLOADS_DIR"
echo "   ✅ Sahiplik verildi: $NGINX_USER:$NGINX_USER"

# Alternatif: Sadece okuma izni ver (sahiplik değiştirmeden)
echo ""
echo "4️⃣ Alternatif: Grup izinleri düzeltiliyor..."
# Nginx kullanıcısını ibrahim grubuna ekle (opsiyonel)
# sudo usermod -a -G ibrahim $NGINX_USER

# Herkesin okuyabilmesi için
chmod -R a+r "$UPLOADS_DIR" 2>/dev/null
echo "   ✅ Okuma izinleri eklendi"

echo ""
echo "5️⃣ İzin kontrolü:"
ls -la "$UPLOADS_DIR" | head -5

echo ""
echo "✅ İşlem tamamlandı!"
echo ""
echo "💡 Test için:"
echo "   npm run test-nginx"

