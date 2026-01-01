#!/bin/bash

# Dugunkarem.com Nginx config zorla düzeltme scripti

echo "🔧 Dugunkarem.com Nginx config zorla düzeltiliyor..."

# Dugunkarem config dosyasını oluştur/güncelle
DUGUNKAREM_CONFIG="/etc/nginx/sites-available/dugunkarem"
DUGUNKAREM_ENABLED="/etc/nginx/sites-enabled/dugunkarem"

echo "📝 Dugunkarem config oluşturuluyor..."
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

# Tüm aktif config'lerden dugunkarem.com'u çıkar
echo "🔍 Tüm Nginx config'lerinden dugunkarem.com çıkarılıyor..."

for config in /etc/nginx/sites-available/*; do
    if [ -f "$config" ] && [ "$config" != "$DUGUNKAREM_CONFIG" ]; then
        config_name=$(basename "$config")
        echo "📋 Kontrol ediliyor: $config_name"
        
        # dugunkarem.com'u çıkar
        if grep -q "dugunkarem\.com" "$config"; then
            echo "   ⚠️ dugunkarem.com bulundu, çıkarılıyor..."
            sudo sed -i "s/dugunkarem\.com //g" "$config"
            sudo sed -i "s/www\.dugunkarem\.com //g" "$config"
            sudo sed -i "s/dugunkarem\.com\.tr //g" "$config"
            sudo sed -i "s/www\.dugunkarem\.com\.tr //g" "$config"
            # Birden fazla boşlukları temizle
            sudo sed -i 's/server_name  */server_name /g' "$config"
            sudo sed -i 's/server_name  */server_name /g' "$config"
            echo "   ✅ $config_name güncellendi"
        fi
    fi
done

# Aktif config'leri de kontrol et
for config in /etc/nginx/sites-enabled/*; do
    if [ -L "$config" ]; then
        real_config=$(readlink -f "$config")
        if [ "$real_config" != "$DUGUNKAREM_CONFIG" ] && [ -f "$real_config" ]; then
            config_name=$(basename "$config")
            echo "📋 Aktif config kontrol ediliyor: $config_name"
            
            if grep -q "dugunkarem\.com" "$real_config"; then
                echo "   ⚠️ dugunkarem.com bulundu, çıkarılıyor..."
                sudo sed -i "s/dugunkarem\.com //g" "$real_config"
                sudo sed -i "s/www\.dugunkarem\.com //g" "$real_config"
                sudo sed -i "s/dugunkarem\.com\.tr //g" "$real_config"
                sudo sed -i "s/www\.dugunkarem\.com\.tr //g" "$real_config"
                sudo sed -i 's/server_name  */server_name /g' "$real_config"
                sudo sed -i 's/server_name  */server_name /g' "$real_config"
                echo "   ✅ $config_name güncellendi"
            fi
        fi
    fi
done

# Default server block'u kontrol et
echo "🔍 Default server block kontrol ediliyor..."
if grep -q "default_server" /etc/nginx/sites-available/* 2>/dev/null; then
    echo "   ⚠️ default_server bulundu, kontrol edin"
    sudo grep -r "default_server" /etc/nginx/sites-available/
fi

# Nginx test ve reload
echo "🔄 Nginx test ediliyor..."
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx reload edildi"
else
    echo "❌ Nginx config hatası!"
    exit 1
fi

# Hangi config'in dugunkarem.com için kullanıldığını göster
echo ""
echo "📋 dugunkarem.com için hangi config kullanılıyor:"
sudo nginx -T 2>/dev/null | grep -A 20 "server_name.*dugunkarem.com" || echo "   ⚠️ dugunkarem.com bulunamadı!"

echo ""
echo "✅ Dugunkarem.com Nginx config düzeltildi!"
echo "📋 Test: curl -I -H 'Host: dugunkarem.com' http://localhost"

