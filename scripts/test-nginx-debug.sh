#!/bin/bash

# Nginx debug test script
# Kullanım: bash scripts/test-nginx-debug.sh

echo "🔍 Nginx debug test..."
echo ""

# Test dosyası
TEST_FILE="instagram-dugunkaremcom-1767121928499-gvlrlg-2019-05-25_15-15-54_UTC.jpg"
TEST_URL="/uploads/$TEST_FILE"

echo "1️⃣ Nginx config kontrolü:"
echo ""
echo "   Foto-ugur config:"
sudo grep -A 3 "server_name.*fotougur" /etc/nginx/sites-available/foto-ugur | head -5
echo ""
echo "   Location /uploads:"
sudo grep -A 5 "location /uploads" /etc/nginx/sites-available/foto-ugur
echo ""

echo "2️⃣ Aktif server block'ları:"
sudo ls -la /etc/nginx/sites-enabled/
echo ""

echo "3️⃣ Test istekleri:"
echo ""

# localhost ile test
echo "   a) localhost:"
curl -s -o /dev/null -w "      HTTP Status: %{http_code}\n      Server: %{server}\n" "http://localhost$TEST_URL"
echo ""

# Host header ile test
echo "   b) Host: fotougur.com.tr:"
curl -s -o /dev/null -w "      HTTP Status: %{http_code}\n      Server: %{server}\n" -H "Host: fotougur.com.tr" "http://localhost$TEST_URL"
echo ""

# IP ile test
echo "   c) IP (127.0.0.1):"
curl -s -o /dev/null -w "      HTTP Status: %{http_code}\n      Server: %{server}\n" "http://127.0.0.1$TEST_URL"
echo ""

echo "4️⃣ Nginx error log (son 3 satır):"
sudo tail -3 /var/log/nginx/error.log
echo ""

echo "5️⃣ Nginx access log (son 3 satır):"
sudo tail -3 /var/log/nginx/access.log 2>/dev/null || echo "   ⚠️ Access log bulunamadı"
echo ""

echo "💡 Öneriler:"
echo "   - Eğer localhost farklı server block kullanıyorsa, default server block'u kontrol edin"
echo "   - location /uploads/ yerine location /uploads kullanmayı deneyin"
echo "   - Host header ile test edin"

