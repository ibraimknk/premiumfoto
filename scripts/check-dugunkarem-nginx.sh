#!/bin/bash

# dugunkarem.com domain'inin hangi nginx config'inde olduğunu bul

echo "🔍 dugunkarem.com domain'i aranıyor..."

# Tüm nginx config dosyalarını kontrol et
echo ""
echo "📋 /etc/nginx/sites-available/ içindeki dosyalar:"
ls -la /etc/nginx/sites-available/ | grep -E "\.(conf|nginx)$|^[^d]"

echo ""
echo "📋 dugunkarem.com içeren config'ler:"
sudo grep -r "dugunkarem\.com" /etc/nginx/sites-available/ 2>/dev/null | grep -v "^Binary"

echo ""
echo "📋 Aktif config'ler (sites-enabled):"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "📋 Her config'teki server_name'ler:"
for config in /etc/nginx/sites-available/*; do
    if [ -f "$config" ]; then
        echo ""
        echo "--- $(basename $config) ---"
        sudo grep "server_name" "$config" | head -5
    fi
done

echo ""
echo "📋 foto-ugur config'inin tamamı:"
sudo cat /etc/nginx/sites-available/foto-ugur

