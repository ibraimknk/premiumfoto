#!/bin/bash

# Dugunkarem frontend hataları düzeltme scripti

echo "🔧 Dugunkarem frontend hataları düzeltiliyor..."

cd /home/ibrahim/dugunkarem/frontend

# SEOHead.js dosyasını bul
SEOHEAD_FILE=$(find src -name "SEOHead.js" -o -name "SEOHead.jsx" | head -1)

if [ -z "$SEOHEAD_FILE" ]; then
    echo "❌ SEOHead.js bulunamadı!"
    echo "📁 Mevcut dosyalar:"
    find src -name "*.js" -o -name "*.jsx" | head -20
else
    echo "✅ SEOHead.js bulundu: $SEOHEAD_FILE"
    
    # 146. satırı kontrol et
    echo "📋 SEOHead.js 146. satır:"
    sed -n '140,150p' "$SEOHEAD_FILE"
    
    # Yedek al
    cp "$SEOHEAD_FILE" "${SEOHEAD_FILE}.backup"
    echo "✅ Yedek oluşturuldu: ${SEOHEAD_FILE}.backup"
    
    # faqs.map() kullanımlarını düzelt
    echo "🔧 SEOHead.js: faqs.map() düzeltiliyor..."
    
    # Tüm faqs.map() kullanımlarını güvenli hale getir
    sed -i 's/faqs\.map(/\(faqs \&\& Array.isArray(faqs) ? faqs : \[\]\).map(/g' "$SEOHEAD_FILE"
    
    # generateFAQSchema fonksiyonunu düzelt
    sed -i 's/"mainEntity": faqs\.map/"mainEntity": (faqs \&\& Array.isArray(faqs) ? faqs : \[\]).map/g' "$SEOHEAD_FILE"
    
    echo "✅ SEOHead.js düzeltildi!"
fi

# HomePage.js dosyasını bul
HOMEPAGE_FILE=$(find src -name "HomePage.js" -o -name "HomePage.jsx" | head -1)

if [ -z "$HOMEPAGE_FILE" ]; then
    echo "⚠️ HomePage.js bulunamadı, alternatif arama..."
    HOMEPAGE_FILE=$(find src -type f \( -name "*Home*" -o -name "*home*" \) | head -1)
fi

if [ -z "$HOMEPAGE_FILE" ]; then
    echo "❌ HomePage.js bulunamadı!"
    echo "📁 Mevcut dosyalar:"
    find src -name "*.js" -o -name "*.jsx" | head -20
else
    echo "✅ HomePage.js bulundu: $HOMEPAGE_FILE"
    
    # 192. satırı kontrol et
    echo "📋 HomePage.js 192. satır:"
    sed -n '185,200p' "$HOMEPAGE_FILE"
    
    # Yedek al
    cp "$HOMEPAGE_FILE" "${HOMEPAGE_FILE}.backup"
    echo "✅ Yedek oluşturuldu: ${HOMEPAGE_FILE}.backup"
    
    # r.slice(...).map() kullanımlarını düzelt
    echo "🔧 HomePage.js: r.slice(...).map() düzeltiliyor..."
    
    # r.slice().map() -> güvenli hale getir
    sed -i 's/\([a-zA-Z_$][a-zA-Z0-9_$]*\)\.slice(\([^)]*\))\.map(/\(Array.isArray(\1) ? \1.slice(\2) : \[\]\).map(/g' "$HOMEPAGE_FILE"
    
    # Alternatif: r.map() kullanımlarını da düzelt
    sed -i 's/\([a-zA-Z_$][a-zA-Z0-9_$]*\)\.map(/\(Array.isArray(\1) ? \1 : \[\]\).map(/g' "$HOMEPAGE_FILE"
    
    # servi is not defined hatası - muhtemelen services olmalı
    echo "🔧 HomePage.js: servi -> services düzeltiliyor..."
    sed -i 's/\bservi\b/services/g' "$HOMEPAGE_FILE"
    
    # Diğer yaygın typo'lar
    sed -i 's/\bservic\b/services/g' "$HOMEPAGE_FILE"
    sed -i 's/\bservice\b/services/g' "$HOMEPAGE_FILE"  # Dikkatli: service -> services olabilir
    
    echo "✅ HomePage.js düzeltildi!"
fi

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

