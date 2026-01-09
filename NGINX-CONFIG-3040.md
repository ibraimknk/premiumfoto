# 🌐 Nginx Config Güncelleme (3 Domain → Port 3040)

## 📋 Durum

- ✅ Sunucu erişilebilir (95.70.203.118)
- ✅ Uygulama port 3040'da çalışıyor
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

# Domain erişimi
curl -I http://fotougur.com.tr
curl -I http://dugunkarem.com
curl -I http://dugunkarem.com.tr

# Nginx logları
sudo tail -f /var/log/nginx/access.log
```

## 🔄 Farklı Projeler İçin

Yeni bir proje eklemek için:

1. **Yeni projeyi farklı portta başlatın (örn: 3041):**
   ```bash
   cd ~/yeni-proje
   pm2 start npm --name "yeni-proje" -- start -- -p 3041
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
   }
   ```

4. **Nginx'i reload edin:**
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

## 📝 Port Yönetimi

Farklı projeler için port planlaması:

- **Port 3040:** Foto Uğur (mevcut)
- **Port 3041:** Yeni Proje 1
- **Port 3042:** Yeni Proje 2
- **Port 3043:** Yeni Proje 3
- ...

Her proje için:
1. Farklı port kullanın
2. Nginx'te ayrı server block oluşturun
3. Domain'i ilgili port'a yönlendirin

## 🎯 Özet

- **Mevcut:** 3 domain → Port 3040 (Foto Uğur)
- **Gelecek:** Her yeni proje → Yeni port → Yeni server block
- **Nginx:** Tüm domain'leri yönetir, her domain farklı porta yönlendirilir

