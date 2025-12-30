#!/bin/bash

# Uploads klasörü izinlerini düzeltme scripti
# Kullanım: bash scripts/fix-uploads-permissions.sh

echo "📁 Uploads klasörü izinleri düzeltiliyor..."

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Uploads klasörünü oluştur (yoksa)
mkdir -p public/uploads

# İzinleri düzelt
# 755 = rwxr-xr-x (owner: read/write/execute, group/others: read/execute)
chmod 755 public/uploads

# Dosyalar için 644 = rw-r--r-- (owner: read/write, group/others: read)
find public/uploads -type f -exec chmod 644 {} \;

# Klasörler için 755
find public/uploads -type d -exec chmod 755 {} \;

# Sahiplik kontrolü (www-data veya nginx kullanıcısı)
# Eğer Nginx www-data kullanıyorsa:
if id "www-data" &>/dev/null; then
    chown -R www-data:www-data public/uploads 2>/dev/null || echo "⚠️ www-data kullanıcısı bulunamadı, sahiplik değiştirilemedi"
fi

# Veya nginx kullanıcısı varsa:
if id "nginx" &>/dev/null; then
    chown -R nginx:nginx public/uploads 2>/dev/null || echo "⚠️ nginx kullanıcısı bulunamadı, sahiplik değiştirilemedi"
fi

# Mevcut kullanıcı için de yazma izni ver
chmod -R u+w public/uploads

echo "✅ İzinler düzeltildi!"
echo ""
echo "📋 Kontrol:"
ls -la public/uploads | head -10
echo ""
echo "📊 Dosya sayısı:"
find public/uploads -type f | wc -l

