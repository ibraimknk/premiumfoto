#!/bin/bash

# Nginx izinlerini düzelten script
# Kullanım: bash scripts/fix-nginx-permissions.sh

echo "🔧 Nginx izinleri düzeltiliyor..."
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Uploads klasörü
UPLOADS_DIR="public/uploads"

# Nginx kullanıcısını bul
NGINX_USER=$(ps aux | grep -E 'nginx: (master|worker)' | head -1 | awk '{print $1}')
if [ -z "$NGINX_USER" ]; then
    # Varsayılan olarak www-data dene
    if id "www-data" &>/dev/null; then
        NGINX_USER="www-data"
    elif id "nginx" &>/dev/null; then
        NGINX_USER="nginx"
    else
        echo "❌ Nginx kullanıcısı bulunamadı!"
        exit 1
    fi
fi

echo "📋 Nginx kullanıcısı: $NGINX_USER"
echo ""

# Uploads klasörünü oluştur
echo "1️⃣ Uploads klasörü kontrol ediliyor..."
mkdir -p "$UPLOADS_DIR"
echo "   ✅ Klasör hazır"

# İzinleri düzelt
echo ""
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

# Herkesin okuyabilmesi için
chmod -R a+r "$UPLOADS_DIR" 2>/dev/null
echo "   ✅ Okuma izinleri eklendi"

# Üst klasörlere de erişim izni ver
chmod 755 public 2>/dev/null
chmod 755 "$(pwd)" 2>/dev/null
echo "   ✅ Üst klasör izinleri: 755"

# Nginx kullanıcısına sahiplik ver (opsiyonel, genellikle gerekmez)
# Ama eğer gerekirse:
# sudo chown -R $NGINX_USER:$NGINX_USER "$UPLOADS_DIR"

echo ""
echo "3️⃣ İzin kontrolü:"
ls -la "$UPLOADS_DIR" | head -5

echo ""
echo "✅ İzinler düzeltildi!"
echo ""
echo "💡 Eğer hala sorun varsa, Nginx kullanıcısına sahiplik verin:"
echo "   sudo chown -R $NGINX_USER:$NGINX_USER $UPLOADS_DIR"

