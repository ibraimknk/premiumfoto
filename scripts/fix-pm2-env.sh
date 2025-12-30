#!/bin/bash

# PM2 environment ve PATH düzeltme scripti
# Kullanım: bash scripts/fix-pm2-env.sh

echo "🔧 PM2 environment düzeltiliyor..."
echo ""

# Proje dizinine git
cd "$(dirname "$0")/.." || exit 1

# Instaloader path'ini bul
echo "1️⃣ Instaloader path'i bulunuyor..."
export PATH="$HOME/.local/bin:$PATH"

INSTALOADER_PATH=$(which instaloader 2>/dev/null)
if [ -z "$INSTALOADER_PATH" ]; then
    # Alternatif yolları kontrol et
    if [ -f "$HOME/.local/bin/instaloader" ]; then
        INSTALOADER_PATH="$HOME/.local/bin/instaloader"
    else
        echo "   ❌ Instaloader bulunamadı! Önce kurun:"
        echo "      npm run install-instaloader"
        exit 1
    fi
fi

echo "   ✅ Instaloader bulundu: $INSTALOADER_PATH"
echo ""

# PM2 app adı
PM2_APP_NAME="foto-ugur-app"

# PM2 ecosystem dosyası oluştur
echo "2️⃣ PM2 ecosystem dosyası oluşturuluyor..."
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: '${PM2_APP_NAME}',
    script: 'npm',
    args: 'start',
    cwd: '$(pwd)',
    env: {
      NODE_ENV: 'production',
      PORT: 3040,
      PATH: '$HOME/.local/bin:' + process.env.PATH,
      HOME: '$HOME'
    },
    error_file: '$HOME/.pm2/logs/${PM2_APP_NAME}-error.log',
    out_file: '$HOME/.pm2/logs/${PM2_APP_NAME}-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    instances: 1,
    exec_mode: 'fork'
  }]
}
EOF

echo "   ✅ ecosystem.config.js oluşturuldu"
echo ""

# PM2'yi durdur
echo "3️⃣ PM2 uygulaması durduruluyor..."
pm2 stop ${PM2_APP_NAME} 2>/dev/null || true
pm2 delete ${PM2_APP_NAME} 2>/dev/null || true
echo "   ✅ PM2 uygulaması durduruldu"
echo ""

# PM2'yi ecosystem ile başlat
echo "4️⃣ PM2 ecosystem ile başlatılıyor..."
pm2 start ecosystem.config.js
pm2 save
echo "   ✅ PM2 başlatıldı"
echo ""

# PM2 durumunu kontrol et
echo "5️⃣ PM2 durumu:"
pm2 status
echo ""

# PM2 environment'ı kontrol et
echo "6️⃣ PM2 environment kontrolü:"
pm2 show ${PM2_APP_NAME} | grep -A 10 "env:"
echo ""

# Test
echo "7️⃣ Instaloader test:"
pm2 logs ${PM2_APP_NAME} --lines 5 --nostream
echo ""

echo "✅ İşlem tamamlandı!"
echo ""
echo "💡 PM2 loglarını izlemek için:"
echo "   pm2 logs ${PM2_APP_NAME}"

