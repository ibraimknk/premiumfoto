#!/bin/bash

# Dugunkarem SEOHead.js düzeltme scripti

echo "🔧 Dugunkarem SEOHead.js düzeltiliyor..."

cd /home/ibrahim/dugunkarem/frontend

# SEOHead.js dosyasını bul
SEOHEAD_FILE=$(find src -name "SEOHead.js" -o -name "SEOHead.jsx" | head -1)

if [ -z "$SEOHEAD_FILE" ]; then
    echo "❌ SEOHead.js bulunamadı!"
    echo "📁 Mevcut dosyalar:"
    find src -name "*.js" -o -name "*.jsx" | head -20
    exit 1
fi

echo "✅ SEOHead.js bulundu: $SEOHEAD_FILE"

# 146. satırı kontrol et
echo "📋 146. satır:"
sed -n '140,150p' "$SEOHEAD_FILE"

# Yedek al
cp "$SEOHEAD_FILE" "${SEOHEAD_FILE}.backup"
echo "✅ Yedek oluşturuldu: ${SEOHEAD_FILE}.backup"

# faqs.map() kullanımlarını düzelt
echo "🔧 faqs.map() düzeltiliyor..."

# Tüm faqs.map() kullanımlarını güvenli hale getir
sed -i 's/faqs\.map(/\(faqs \&\& Array.isArray(faqs) ? faqs : \[\]\).map(/g' "$SEOHEAD_FILE"

# generateFAQSchema fonksiyonunu düzelt
sed -i 's/"mainEntity": faqs\.map/"mainEntity": (faqs \&\& Array.isArray(faqs) ? faqs : \[\]).map/g' "$SEOHEAD_FILE"

echo "✅ SEOHead.js düzeltildi!"

# Değişiklikleri göster
echo ""
echo "📋 Düzeltilen satırlar:"
grep -n "faqs.*map" "$SEOHEAD_FILE" | head -5

echo ""
echo "🏗️ Build yapılıyor..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Build başarılı!"
    echo "🔄 PM2 yeniden başlatılıyor..."
    pm2 restart dugunkarem-app
    echo "✅ PM2 yeniden başlatıldı!"
else
    echo "❌ Build başarısız! Lütfen hataları kontrol edin."
    exit 1
fi

echo ""
echo "✅ Düzeltme tamamlandı!"

