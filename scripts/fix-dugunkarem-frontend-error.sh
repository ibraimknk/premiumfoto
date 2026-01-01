#!/bin/bash

# Dugunkarem frontend hata düzeltme scripti

echo "🔧 Dugunkarem frontend hatası kontrol ediliyor..."

cd /home/ibrahim/dugunkarem/frontend

# SEOHead.js dosyasını kontrol et
if [ -f "src/components/SEOHead.js" ]; then
    echo "📋 SEOHead.js bulundu, 146. satır kontrol ediliyor..."
    sed -n '140,150p' src/components/SEOHead.js
    
    echo ""
    echo "💡 Eğer 'e.map' görüyorsanız, şu şekilde düzeltin:"
    echo "   ÖNCE: e.map(item => ...)"
    echo "   SONRA: (e && Array.isArray(e) ? e : []).map(item => ...)"
else
    echo "⚠️ SEOHead.js bulunamadı"
    echo "📁 Mevcut dosyalar:"
    find src -name "*.js" -o -name "*.jsx" | head -10
fi

# HomePage.js dosyasını kontrol et
if [ -f "src/components/HomePage.js" ]; then
    echo ""
    echo "📋 HomePage.js bulundu, 85. satır kontrol ediliyor..."
    sed -n '80,90p' src/components/HomePage.js
fi

echo ""
echo "✅ Kontrol tamamlandı!"
echo "💡 Dosyaları düzelttikten sonra: npm run build && pm2 restart dugunkarem-app"

