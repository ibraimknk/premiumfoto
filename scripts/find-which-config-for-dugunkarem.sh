#!/bin/bash

# dugunkarem.com için hangi config kullanılıyor?

echo "🔍 dugunkarem.com için hangi config kullanılıyor?"

echo ""
echo "📋 Nginx'in yüklediği tüm config'lerde dugunkarem.com:"
sudo nginx -T 2>/dev/null | grep -B 15 -A 5 "dugunkarem\.com" | head -50

echo ""
echo "📋 443 portu için tüm server block'ları:"
sudo nginx -T 2>/dev/null | grep -B 5 -A 10 "listen.*443" | grep -E "server_name|ssl_certificate|listen.*443" | head -30

echo ""
echo "📋 fikirtepetekelpaket.com config'i:"
sudo cat /etc/nginx/sites-available/fikirtepetekelpaket.com | grep -B 5 -A 15 "server_name\|listen.*443"

echo ""
echo "📋 foto-ugur config'indeki dugunkarem.com server block'u:"
sudo cat /etc/nginx/sites-available/foto-ugur | grep -B 5 -A 20 "server_name.*dugunkarem\.com.*dugunkarem\.com\.tr"

