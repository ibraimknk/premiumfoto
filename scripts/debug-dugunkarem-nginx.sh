#!/bin/bash

# dugunkarem.com için Nginx debug

echo "🔍 dugunkarem.com için Nginx debug..."

echo ""
echo "📋 Nginx'in yüklediği tüm config'lerde dugunkarem.com:"
sudo nginx -T 2>/dev/null | grep -B 20 -A 5 "dugunkarem\.com" | head -60

echo ""
echo "📋 443 portu için tüm server block'ları (sırayla):"
sudo nginx -T 2>/dev/null | grep -B 3 -A 8 "listen.*443" | grep -E "server_name|ssl_certificate|listen.*443|# configuration file" | head -40

echo ""
echo "📋 fikirtepetekelpaket.com config'i tam:"
sudo cat /etc/nginx/sites-available/fikirtepetekelpaket.com

echo ""
echo "📋 foto-ugur config'inin ilk 50 satırı:"
sudo head -50 /etc/nginx/sites-available/foto-ugur

echo ""
echo "📋 foto-ugur config'indeki dugunkarem.com server block'u:"
sudo grep -B 5 -A 25 "server_name.*dugunkarem\.com.*dugunkarem\.com\.tr" /etc/nginx/sites-available/foto-ugur

