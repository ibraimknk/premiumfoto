#!/bin/bash

# Dugunkarem.com Nginx config düzeltme scripti

echo "🔧 Dugunkarem.com Nginx config düzeltiliyor..."

# Dugunkarem config dosyasını kontrol et
DUGUNKAREM_CONFIG="/etc/nginx/sites-available/dugunkarem"
DUGUNKAREM_ENABLED="/etc/nginx/sites-enabled/dugunkarem"

# Config dosyasını oluştur/güncelle
sudo tee "$DUGUNKAREM_CONFIG" > /dev/null << 'EOF'
server {
    listen 80;
    server_name dugunkarem.com;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:3042;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Uploads için statik dosya servisi
    location /uploads {
        alias /home/ibrahim/dugunkarem/frontend/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }
}
EOF

# Site'ı aktif et
if [ ! -L "$DUGUNKAREM_ENABLED" ]; then
    sudo ln -s "$DUGUNKAREM_CONFIG" "$DUGUNKAREM_ENABLED"
    echo "✅ Dugunkarem site aktif edildi"
fi

# Diğer config'lerde dugunkarem.com'un olmadığından emin ol
echo "🔍 Diğer Nginx config'leri kontrol ediliyor..."

# Tüm aktif config'leri kontrol et
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ] && [ "$config" != "$DUGUNKAREM_ENABLED" ]; then
        config_name=$(basename "$config")
        echo "📋 Kontrol ediliyor: $config_name"
        
        # dugunkarem.com'u çıkar
        if grep -q "dugunkarem\.com" "$config"; then
            echo "   ⚠️ dugunkarem.com bulundu, çıkarılıyor..."
            sudo sed -i "s/dugunkarem\.com //g" "$config"
            sudo sed -i "s/www\.dugunkarem\.com //g" "$config"
            sudo sed -i 's/server_name  */server_name /g' "$config"
            echo "   ✅ $config_name güncellendi"
        fi
    fi
done

# Nginx test ve reload
echo "🔄 Nginx test ediliyor..."
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx reload edildi"
else
    echo "❌ Nginx config hatası!"
    exit 1
fi

echo ""
echo "✅ Dugunkarem.com Nginx config düzeltildi!"
echo "📋 Kontrol:"
echo "   - Config: $DUGUNKAREM_CONFIG"
echo "   - Aktif: $DUGUNKAREM_ENABLED"
echo "   - Port: 3042"
echo "   - Domain: dugunkarem.com"

