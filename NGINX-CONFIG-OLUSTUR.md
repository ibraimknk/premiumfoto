# 🌐 Nginx Config Oluşturma

## ✅ Durum

- ✅ Uygulama port 3041'de çalışıyor
- ✅ PM2 "online" durumda
- ❌ Nginx config dosyası yok

## 🚀 Nginx Config Oluşturma

### 1. Nginx Config Dosyasını Oluştur

```bash
sudo nano /etc/nginx/sites-available/foto-ugur
```

Aşağıdaki içeriği yapıştırın:

```nginx
server {
    listen 80;
    server_name fotougur.com.tr www.fotougur.com.tr dugunkarem.com www.dugunkarem.com dugunkarem.com.tr www.dugunkarem.com.tr;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:3041;
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
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }
}
```

Kaydedin: `Ctrl+O`, `Enter`, `Ctrl+X`

### 2. Nginx Site'ı Aktif Et

```bash
# Site'ı aktif et
sudo ln -sf /etc/nginx/sites-available/foto-ugur /etc/nginx/sites-enabled/

# Test et
sudo nginx -t

# Yeniden yükle
sudo systemctl reload nginx
```

## 🔥 Tek Komutla Tüm İşlemler

```bash
sudo tee /etc/nginx/sites-available/foto-ugur > /dev/null << 'EOF'
server {
    listen 80;
    server_name fotougur.com.tr www.fotougur.com.tr dugunkarem.com www.dugunkarem.com dugunkarem.com.tr www.dugunkarem.com.tr;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:3041;
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

sudo ln -sf /etc/nginx/sites-available/foto-ugur /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## ✅ Doğrulama

```bash
# Nginx config kontrolü
sudo cat /etc/nginx/sites-available/foto-ugur | grep proxy_pass
# Çıktı: proxy_pass http://localhost:3041; olmalı

# Nginx durumu
sudo systemctl status nginx

# Domain'lerin erişilebilirliği
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr
```

## 📝 Notlar

1. **Port:** Nginx artık port 3041'e proxy yapıyor
2. **Domain'ler:** 3 domain (ve www versiyonları) yapılandırıldı
3. **Uploads:** `/uploads` klasörü doğrudan Nginx tarafından servis ediliyor
4. **SSL:** SSL sertifikası kurmak için `certbot` kullanabilirsiniz

