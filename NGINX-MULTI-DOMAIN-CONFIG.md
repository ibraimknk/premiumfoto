# 🌐 Nginx Multi-Domain Yapılandırması

## 📋 Mevcut Durum

- ✅ Sunucu erişilebilir (95.70.203.118)
- ✅ Uygulama port 3041'de çalışıyor
- ✅ 3 domain: fotougur.com.tr, dugunkarem.com, dugunkarem.com.tr
- ✅ Nginx port 80'de dinliyor

## 🚀 Nginx Config Güncelleme

### Mevcut Config (Tüm Domain'ler Aynı Uygulamaya)

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

    location /uploads {
        alias /home/ibrahim/premiumfoto/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }
}
```

### Gelecekte Farklı Projeler İçin

Farklı projeler eklemek için her domain için ayrı server block oluşturun:

```nginx
# Foto Uğur - Port 3041
server {
    listen 80;
    server_name fotougur.com.tr www.fotougur.com.tr;

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

# Düğün Karem - Port 3041 (aynı uygulama)
server {
    listen 80;
    server_name dugunkarem.com www.dugunkarem.com dugunkarem.com.tr www.dugunkarem.com.tr;

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

# Gelecekte farklı proje için örnek:
# server {
#     listen 80;
#     server_name yeni-proje.com www.yeni-proje.com;
#     location / {
#         proxy_pass http://localhost:3042;  # Farklı port
#         # ... aynı proxy ayarları
#     }
# }
```

## 🔧 Sunucuda Yapılacaklar

### 1. Nginx Config'i Güncelle

```bash
sudo nano /etc/nginx/sites-available/foto-ugur
```

Yukarıdaki config'i yapıştırın ve kaydedin.

### 2. Nginx Test ve Reload

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 📝 Yeni Proje Ekleme

Yeni bir proje eklemek için:

1. **Yeni projeyi farklı portta başlatın:**
   ```bash
   # Örnek: Port 3042'de yeni proje
   pm2 start npm --name "yeni-proje" -- start -- -p 3042
   ```

2. **Nginx config'e yeni server block ekleyin:**
   ```bash
   sudo nano /etc/nginx/sites-available/foto-ugur
   ```

3. **Yeni domain için server block ekleyin:**
   ```nginx
   server {
       listen 80;
       server_name yeni-proje.com www.yeni-proje.com;
       location / {
           proxy_pass http://localhost:3042;
           # ... aynı proxy ayarları
       }
   }
   ```

4. **Nginx'i reload edin:**
   ```bash
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

## 🎯 Özet

- **Mevcut:** 3 domain → Port 3041 (aynı uygulama)
- **Gelecek:** Her domain için ayrı server block → Farklı portlar
- **Yeni Proje:** Yeni domain → Yeni port → Yeni server block

