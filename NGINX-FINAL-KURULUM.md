# 🌐 Nginx Final Kurulum (Port 3040)

## ✅ Durum

- ✅ `package.json` port 3040'a güncellendi
- ✅ PM2 "online" durumda
- ✅ Git pull başarılı
- ⏳ Nginx config güncellenmeli

## 🚀 Nginx Config Güncelleme

### Sunucuda Çalıştırılacak Komut

```bash
sudo tee /etc/nginx/sites-available/foto-ugur > /dev/null << 'EOF'
server {
    listen 80;
    server_name fotougur.com.tr www.fotougur.com.tr dugunkarem.com www.dugunkarem.com dugunkarem.com.tr www.dugunkarem.com.tr;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:3040;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /uploads {
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }
}
EOF

# Site'ı aktif et
sudo ln -sf /etc/nginx/sites-available/foto-ugur /etc/nginx/sites-enabled/

# Test et
sudo nginx -t

# Reload
sudo systemctl reload nginx
```

## ✅ Doğrulama

```bash
# Nginx config test
sudo nginx -t

# Nginx durumu
sudo systemctl status nginx

# Port 3040 kontrolü
sudo lsof -i:3040
# node process görünmeli

# Port 80 kontrolü
sudo lsof -i:80 | grep nginx
# nginx process görünmeli

# Domain erişimi (local test)
curl -I http://localhost
# HTTP 200 dönmeli

# Nginx logları
sudo tail -f /var/log/nginx/access.log
```

## 🎯 Özet

- ✅ Uygulama port 3040'da çalışıyor
- ✅ PM2 "online" durumda
- ✅ Nginx config port 3040'a yönlendirilecek
- ✅ 3 domain (fotougur.com.tr, dugunkarem.com, dugunkarem.com.tr) port 3040'a yönlendirilecek

