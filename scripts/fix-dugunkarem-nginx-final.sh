#!/bin/bash

# Dugunkarem.com Nginx config final düzeltme scripti

echo "🔧 Dugunkarem.com Nginx config final düzeltme..."

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

# Tüm config'lerden dugunkarem.com'u çıkar (aktas-market dahil)
echo "🔍 Tüm Nginx config'lerinden dugunkarem.com çıkarılıyor..."

for config in /etc/nginx/sites-available/*; do
    if [ -f "$config" ] && [ "$config" != "$DUGUNKAREM_CONFIG" ]; then
        config_name=$(basename "$config")
        
        # dugunkarem.com'u çıkar
        if grep -q "dugunkarem\.com" "$config"; then
            echo "   ⚠️ $config_name'de dugunkarem.com bulundu, çıkarılıyor..."
            sudo sed -i "s/dugunkarem\.com //g" "$config"
            sudo sed -i "s/www\.dugunkarem\.com //g" "$config"
            sudo sed -i "s/dugunkarem\.com\.tr //g" "$config"
            sudo sed -i "s/www\.dugunkarem\.com\.tr //g" "$config"
            sudo sed -i "s/www\.www\.dugunkarem\.com\.tr //g" "$config"
            # Birden fazla boşlukları temizle
            sudo sed -i 's/server_name  */server_name /g' "$config"
            sudo sed -i 's/server_name  */server_name /g' "$config"
            echo "   ✅ $config_name güncellendi"
        fi
    fi
done

# Özellikle aktas-market config'ini kontrol et
AKTAS_CONFIG="/etc/nginx/sites-available/aktas-market"
if [ -f "$AKTAS_CONFIG" ]; then
    echo "📋 Aktas-market config kontrol ediliyor..."
    if grep -q "dugunkarem\.com" "$AKTAS_CONFIG"; then
        echo "   ⚠️ Aktas-market'te dugunkarem.com bulundu, çıkarılıyor..."
        sudo sed -i "s/dugunkarem\.com //g" "$AKTAS_CONFIG"
        sudo sed -i "s/www\.dugunkarem\.com //g" "$AKTAS_CONFIG"
        sudo sed -i 's/server_name  */server_name /g' "$AKTAS_CONFIG"
        echo "   ✅ Aktas-market güncellendi"
    fi
    # Aktas-market config'ini göster
    echo "   📄 Aktas-market server_name:"
    sudo grep "server_name" "$AKTAS_CONFIG" | head -1
fi

# Dugunkarem config'inin öncelikli olması için dosya adını kontrol et
# Nginx alfabetik sıraya göre okur, dugunkarem'in önce gelmesi için
echo "📋 Aktif config sırası:"
ls -1 /etc/nginx/sites-enabled/ | sort

# Nginx test ve reload
echo "🔄 Nginx test ediliyor..."
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx reload edildi"
else
    echo "❌ Nginx config hatası!"
    exit 1
fi

# Test
echo ""
echo "📋 Test sonuçları:"
echo "1. Dugunkarem.com config:"
sudo nginx -T 2>/dev/null | grep -B 2 -A 15 "server_name.*dugunkarem.com" | head -20

echo ""
echo "2. Localhost test:"
curl -I -H "Host: dugunkarem.com" http://localhost 2>&1 | head -5

echo ""
echo "✅ Dugunkarem.com Nginx config düzeltildi!"

