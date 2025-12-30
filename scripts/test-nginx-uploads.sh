#!/bin/bash

# Nginx uploads erişimini test eden script
# Kullanım: bash scripts/test-nginx-uploads.sh

echo "🧪 Nginx uploads erişimi test ediliyor..."
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# İlk Instagram dosyasını bul
FIRST_FILE=$(ls public/uploads/instagram-*.jpg 2>/dev/null | head -1)

if [ -z "$FIRST_FILE" ]; then
    echo "❌ Test için Instagram dosyası bulunamadı!"
    exit 1
fi

# Dosya adını al
FILE_NAME=$(basename "$FIRST_FILE")
FILE_PATH="/uploads/$FILE_NAME"

echo "📋 Test dosyası: $FILE_NAME"
echo "📁 Dosya yolu: $FILE_PATH"
echo ""

# Dosya var mı kontrol et
if [ ! -f "$FIRST_FILE" ]; then
    echo "❌ Dosya bulunamadı: $FIRST_FILE"
    exit 1
fi

echo "✅ Dosya mevcut: $FIRST_FILE"
echo ""

# İzinleri kontrol et
echo "📋 Dosya izinleri:"
ls -la "$FIRST_FILE"
echo ""

# Nginx config kontrolü
echo "🔍 Nginx config kontrolü:"
echo ""
sudo cat /etc/nginx/sites-available/foto-ugur | grep -A 5 "location /uploads"
echo ""

# Localhost üzerinden test
echo "🌐 Localhost üzerinden test:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost$FILE_PATH")
echo "   HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Dosya erişilebilir!"
elif [ "$HTTP_CODE" = "404" ]; then
    echo "   ❌ 404 Not Found - Nginx dosyayı bulamıyor"
    echo ""
    echo "💡 Olası sorunlar:"
    echo "   1. Nginx config path yanlış olabilir"
    echo "   2. Nginx'in dosyalara erişim izni yok"
    echo "   3. location /uploads ile /uploads/ arasında fark olabilir"
elif [ "$HTTP_CODE" = "403" ]; then
    echo "   ❌ 403 Forbidden - Nginx'in dosyaya erişim izni yok"
    echo ""
    echo "💡 Çözüm:"
    echo "   sudo chmod -R 755 public/uploads"
    echo "   sudo chown -R www-data:www-data public/uploads"
else
    echo "   ⚠️ Beklenmeyen durum: $HTTP_CODE"
fi

echo ""
echo "📋 Nginx error log kontrolü:"
echo "   sudo tail -20 /var/log/nginx/error.log"
echo ""

# Gerçek domain üzerinden test (opsiyonel)
echo "🌐 Domain üzerinden test (opsiyonel):"
echo "   curl -I https://fotougur.com.tr$FILE_PATH"
echo "   curl -I https://dugunkarem.com.tr$FILE_PATH"

