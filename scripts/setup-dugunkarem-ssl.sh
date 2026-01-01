#!/bin/bash

# Dugunkarem.com SSL kurulum scripti

echo "🔒 Dugunkarem.com SSL sertifikası kuruluyor..."

DOMAIN="dugunkarem.com"

# Certbot ile SSL kur
echo "📝 Certbot çalıştırılıyor..."
sudo certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email ibrahim@example.com || {
    echo "⚠️ Certbot başarısız, manuel kurulum gerekebilir"
    echo "💡 Manuel kurulum: sudo certbot --nginx -d ${DOMAIN}"
}

# Nginx reload
echo "🔄 Nginx reload ediliyor..."
sudo systemctl reload nginx

echo ""
echo "✅ SSL kurulumu tamamlandı!"
echo "📋 Test: curl -I https://${DOMAIN}"

