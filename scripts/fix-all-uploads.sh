#!/bin/bash

# Tüm uploads sorunlarını düzelten kapsamlı script
# Kullanım: bash scripts/fix-all-uploads.sh

echo "🔧 Uploads klasörü ve görseller düzeltiliyor..."
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# 1. Durum kontrolü
echo "1️⃣ Durum kontrolü yapılıyor..."
node scripts/check-uploads-status.js

echo ""
echo "2️⃣ İzinler düzeltiliyor..."

# Uploads klasörünü oluştur (yoksa)
mkdir -p public/uploads

# İzinleri düzelt
chmod 755 public/uploads
find public/uploads -type f -exec chmod 644 {} \; 2>/dev/null || true
find public/uploads -type d -exec chmod 755 {} \; 2>/dev/null || true
chmod -R a+r public/uploads 2>/dev/null || true

echo "✅ İzinler düzeltildi"

echo ""
echo "3️⃣ Veritabanı URL'leri düzeltiliyor..."
node scripts/fix-instagram-db-urls.js

echo ""
echo "4️⃣ Nginx config kontrolü..."
echo "   ℹ️ Nginx config dosyasını kontrol edin:"
echo "      sudo cat /etc/nginx/sites-available/foto-ugur | grep -A 3 'location /uploads'"
echo ""
echo "   📋 Doğru path olmalı: /home/ibrahim/premiumfoto/public/uploads/"
echo ""
echo "   🔧 Nginx config'i güncellemek için:"
echo "      sudo nano /etc/nginx/sites-available/foto-ugur"
echo "      # Şu satırı bulun:"
echo "      # alias /home/ibrahim/fotougur-app/public/uploads/;"
echo "      # Şöyle değiştirin:"
echo "      # alias /home/ibrahim/premiumfoto/public/uploads/;"
echo ""
echo "   🔄 Nginx'i reload etmek için:"
echo "      sudo nginx -t && sudo systemctl reload nginx"

echo ""
echo "✅ İşlemler tamamlandı!"
echo ""
echo "📋 Son kontrol:"
node scripts/check-uploads-status.js

