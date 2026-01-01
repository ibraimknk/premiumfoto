#!/bin/bash

# Dugunkarem.com durum kontrolü

echo "🔍 Dugunkarem.com durum kontrolü..."
echo ""

# 1. PM2 durumu
echo "1️⃣ PM2 Durumu:"
pm2 list | grep dugunkarem-app || echo "   ❌ dugunkarem-app bulunamadı"
echo ""

# 2. Port 3042 kontrolü
echo "2️⃣ Port 3042 Kontrolü:"
sudo lsof -i:3042 || echo "   ❌ Port 3042'de hiçbir şey dinlemiyor"
echo ""

# 3. PM2 logları (son 10 satır)
echo "3️⃣ PM2 Logları (son 10 satır):"
pm2 logs dugunkarem-app --lines 10 --nostream 2>&1 | tail -10
echo ""

# 4. Build klasörü kontrolü
echo "4️⃣ Build Klasörü:"
if [ -d "/home/ibrahim/dugunkarem/frontend/build" ]; then
    echo "   ✅ Build klasörü mevcut"
    ls -lh /home/ibrahim/dugunkarem/frontend/build | head -5
else
    echo "   ❌ Build klasörü bulunamadı!"
fi
echo ""

# 5. Ecosystem config kontrolü
echo "5️⃣ PM2 Ecosystem Config:"
if [ -f "/home/ibrahim/dugunkarem/frontend/ecosystem.config.js" ]; then
    echo "   ✅ Ecosystem config mevcut"
    cat /home/ibrahim/dugunkarem/frontend/ecosystem.config.js
else
    echo "   ❌ Ecosystem config bulunamadı!"
fi
echo ""

# 6. Nginx config kontrolü
echo "6️⃣ Nginx Config:"
sudo cat /etc/nginx/sites-available/dugunkarem | grep -A 3 "server_name"
echo ""

# 7. Localhost test
echo "7️⃣ Localhost Test:"
curl -I -H "Host: dugunkarem.com" http://localhost 2>&1 | head -5
echo ""

# 8. Serve komutu kontrolü
echo "8️⃣ Serve Komutu:"
which serve || echo "   ❌ serve komutu bulunamadı!"
serve --version 2>&1 | head -1 || echo "   ⚠️ serve çalışmıyor"
echo ""

echo "✅ Kontrol tamamlandı!"

