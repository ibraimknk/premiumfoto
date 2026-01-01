#!/bin/bash

# dugunkarem.com ve dugunkarem.com.tr'yi 3040 portuna yönlendirme

echo "🔧 dugunkarem.com ve dugunkarem.com.tr 3040 portuna yönlendiriliyor..."

# foto-ugur config'ine dugunkarem domain'lerini ekle
FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

if [ ! -f "$FOTO_UGUR_CONFIG" ]; then
    echo "❌ foto-ugur config bulunamadı!"
    exit 1
fi

echo "📝 foto-ugur config güncelleniyor..."

# Mevcut server_name'i al
CURRENT_SERVER_NAME=$(grep "server_name" "$FOTO_UGUR_CONFIG" | head -1 | sed 's/server_name//' | sed 's/;//' | xargs)

# dugunkarem.com ve dugunkarem.com.tr ekle (eğer yoksa)
# Önce mevcut www subdomain'lerini temizle (DNS kayıtları yok)
sudo sed -i "s/www\.dugunkarem\.com //g" "$FOTO_UGUR_CONFIG"
sudo sed -i "s/www\.dugunkarem\.com\.tr //g" "$FOTO_UGUR_CONFIG"
sudo sed -i 's/server_name  */server_name /g' "$FOTO_UGUR_CONFIG"

# Mevcut server_name'i tekrar al (temizlemeden sonra)
CURRENT_SERVER_NAME=$(grep "server_name" "$FOTO_UGUR_CONFIG" | head -1 | sed 's/server_name//' | sed 's/;//' | xargs)

if ! echo "$CURRENT_SERVER_NAME" | grep -q "dugunkarem\.com"; then
    NEW_SERVER_NAME="$CURRENT_SERVER_NAME dugunkarem.com dugunkarem.com.tr"
    sudo sed -i "s/server_name.*;/server_name $NEW_SERVER_NAME;/" "$FOTO_UGUR_CONFIG"
    echo "✅ dugunkarem domain'leri eklendi"
else
    echo "✅ dugunkarem domain'leri zaten mevcut"
fi

# dugunkarem config'ini devre dışı bırak (eğer varsa)
DUGUNKAREM_CONFIG="/etc/nginx/sites-available/dugunkarem"
DUGUNKAREM_ENABLED="/etc/nginx/sites-enabled/dugunkarem"

if [ -L "$DUGUNKAREM_ENABLED" ]; then
    echo "🗑️  dugunkarem config devre dışı bırakılıyor..."
    sudo rm "$DUGUNKAREM_ENABLED"
    echo "✅ dugunkarem config devre dışı bırakıldı"
fi

# Nginx test ve reload
echo "🔄 Nginx test ediliyor..."
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx reload edildi"
else
    echo "❌ Nginx config hatası!"
    exit 1
fi

# SSL sertifikası kur
echo ""
echo "🔒 SSL sertifikası kuruluyor..."

# Certbot ile SSL kur (sadece ana domain'ler için, www yok)
sudo certbot --nginx -d dugunkarem.com -d dugunkarem.com.tr --non-interactive --agree-tos --email ibrahim@example.com 2>&1 || {
    echo "⚠️ Certbot başarısız, manuel kurulum gerekebilir"
    echo "💡 Manuel kurulum:"
    echo "   sudo certbot --nginx -d dugunkarem.com -d dugunkarem.com.tr"
}

# Nginx reload
sudo systemctl reload nginx

echo ""
echo "✅ Yönlendirme ve SSL kurulumu tamamlandı!"
echo ""
echo "📋 Domain yönlendirmeleri:"
echo "   - dugunkarem.com → Port 3040 (premiumfoto)"
echo "   - dugunkarem.com.tr → Port 3040 (premiumfoto)"
echo ""
echo "📋 Test:"
echo "   curl -I https://dugunkarem.com"
echo "   curl -I https://dugunkarem.com.tr"

