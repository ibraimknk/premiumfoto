#!/bin/bash

# Tüm nginx config dosyalarında dugunkarem.com'u bul

echo "🔍 Tüm nginx config dosyalarında dugunkarem.com aranıyor..."

echo ""
echo "📋 /etc/nginx/sites-available/ içindeki tüm dosyalar:"
ls -la /etc/nginx/sites-available/

echo ""
echo "📋 dugunkarem.com içeren tüm config'ler:"
sudo grep -r "dugunkarem\.com" /etc/nginx/sites-available/ 2>/dev/null | grep -v "^Binary" | grep -v ".backup"

echo ""
echo "📋 Aktif config'ler (sites-enabled):"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "📋 Her aktif config'teki server_name'ler:"
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        echo ""
        echo "--- $(basename $config) ---"
        sudo grep "server_name" "$config" | head -5
    fi
done

echo ""
echo "📋 443 portu için tüm server block'ları:"
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        echo ""
        echo "--- $(basename $config) ---"
        sudo grep -B 3 -A 10 "listen 443" "$config" | grep -E "server_name|ssl_certificate|listen 443" | head -10
    fi
done

