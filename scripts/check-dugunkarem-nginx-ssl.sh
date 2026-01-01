#!/bin/bash

# dugunkarem.com için Nginx SSL yapılandırmasını kontrol et

set -e

FOTO_UGUR_CONFIG="/etc/nginx/sites-available/foto-ugur"

echo "🔍 dugunkarem.com SSL yapılandırması kontrol ediliyor..."

echo ""
echo "📋 Tüm 443 portu server block'ları:"
sudo grep -B 3 -A 15 "listen 443" "$FOTO_UGUR_CONFIG" | grep -E "server_name|ssl_certificate|listen 443"

echo ""
echo "📋 dugunkarem.com için server block:"
sudo grep -B 5 -A 20 "server_name.*dugunkarem.com" "$FOTO_UGUR_CONFIG" | head -30

echo ""
echo "📋 Test: Hangi server block kullanılıyor?"
echo "   openssl s_client -connect dugunkarem.com:443 -servername dugunkarem.com < /dev/null 2>/dev/null | grep -E 'subject=|CN='"

