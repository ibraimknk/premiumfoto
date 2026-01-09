# 🌐 Nginx Config Güncelleme (3 Domain → Port 3041)

## 📋 Durum

- ✅ Sunucu erişilebilir (95.70.203.118)
- ✅ Uygulama port 3041'de çalışıyor
- ✅ 3 domain: fotougur.com.tr, dugunkarem.com, dugunkarem.com.tr
- ✅ Nginx port 80'de dinliyor

## 🚀 Nginx Config Güncelleme

### Sunucuda Çalıştırılacak Komut

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

# Site'ı aktif et
sudo ln -sf /etc/nginx/sites-available/foto-ugur /etc/nginx/sites-enabled/

# Test et
sudo nginx -t

# Reload
sudo systemctl reload nginx
```

## 🔄 Farklı Projeler İçin Yapılandırma

Gelecekte farklı projeler eklemek için her domain için ayrı server block oluşturun:

### Örnek: Yeni Proje Ekleme

```bash
# 1. Yeni projeyi farklı portta başlat (örn: 3042)
cd ~/yeni-proje
pm2 start npm --name "yeni-proje" -- start -- -p 3042

# 2. Nginx config'e yeni server block ekle
sudo nano /etc/nginx/sites-available/foto-ugur
```

Yeni server block ekleyin:
```nginx
# Yeni Proje - Port 3042
server {
    listen 80;
    server_name yeni-proje.com www.yeni-proje.com;

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
}
```

```bash
# 3. Nginx'i reload et
sudo nginx -t
sudo systemctl reload nginx
```

## ✅ Doğrulama

```bash
# Nginx config test
sudo nginx -t

# Nginx durumu
sudo systemctl status nginx

# Domain erişimi
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr

# Nginx logları
sudo tail -f /var/log/nginx/access.log
```

## 📝 Port Yönetimi

Farklı projeler için port planlaması:

- **Port 3041:** Foto Uğur (mevcut)
- **Port 3042:** Yeni Proje 1
- **Port 3043:** Yeni Proje 2
- **Port 3044:** Yeni Proje 3
- ...

Her proje için:
1. Farklı port kullanın
2. Nginx'te ayrı server block oluşturun
3. Domain'i ilgili port'a yönlendirin

## 🎯 Özet

- **Mevcut:** 3 domain → Port 3041 (Foto Uğur)
- **Gelecek:** Her yeni proje → Yeni port → Yeni server block
- **Nginx:** Tüm domain'leri yönetir, her domain farklı porta yönlendirilir

