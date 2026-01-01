#!/bin/bash

# Dugunkarem PM2 düzeltme scripti

echo "🔧 Dugunkarem PM2 düzeltiliyor..."

cd /home/ibrahim/dugunkarem/frontend

# PM2'yi durdur
pm2 delete dugunkarem-app 2>/dev/null || true

# Shell script oluştur (serve komutunu çalıştıracak)
cat > start-serve.sh << 'EOF'
#!/bin/bash
cd /home/ibrahim/dugunkarem/frontend
exec serve -s build -l 3042
EOF

chmod +x start-serve.sh

# PM2 ecosystem config oluştur (shell script kullan)
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'dugunkarem-app',
    script: '/home/ibrahim/dugunkarem/frontend/start-serve.sh',
    cwd: '/home/ibrahim/dugunkarem/frontend',
    env: {
      NODE_ENV: 'production',
      PORT: 3042,
      PATH: process.env.PATH
    },
    error_file: '/home/ibrahim/.pm2/logs/dugunkarem-app-error.log',
    out_file: '/home/ibrahim/.pm2/logs/dugunkarem-app-out.log',
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

# PM2'yi başlat
pm2 start ecosystem.config.js
pm2 save

# Durumu kontrol et
echo ""
echo "📊 PM2 Durumu:"
pm2 status | grep dugunkarem

echo ""
echo "🔍 Port 3042 Kontrolü:"
sudo lsof -i:3042 || echo "   ⚠️ Port 3042'de henüz dinleme yok (birkaç saniye bekleyin)"

echo ""
echo "📋 PM2 Logları (son 5 satır):"
pm2 logs dugunkarem-app --lines 5 --nostream 2>&1 | tail -5

echo ""
echo "✅ PM2 düzeltildi!"

