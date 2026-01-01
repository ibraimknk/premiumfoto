# 🌐 Dugunkarem.com Ayrı Proje Kurulumu

## 📋 Durum

- ✅ `fotougur.com.tr` ve `dugunkarem.com.tr` → `premiumfoto` projesi (port 3040)
- ✅ `dugunkarem.com` → `dugunkarem` projesi (port 3041) - YENİ

## 🚀 Kurulum

### 1. Deploy Script'ini Çalıştır

```bash
cd ~/premiumfoto
git pull origin main
chmod +x deploy-dugunkarem.sh
bash deploy-dugunkarem.sh
```

### 2. SSL Sertifikası Kur (Opsiyonel)

```bash
sudo certbot --nginx -d dugunkarem.com -d www.dugunkarem.com
```

## 📊 Proje Yapısı

```
/home/ibrahim/
├── premiumfoto/          # fotougur.com.tr, dugunkarem.com.tr (port 3040)
│   └── PM2: foto-ugur-app
│
└── dugunkarem/           # dugunkarem.com (port 3041)
    └── PM2: dugunkarem-app
```

## 🔧 Nginx Yapılandırması

### Foto-Ugur Config (fotougur.com.tr, dugunkarem.com.tr)

```nginx
server {
    listen 80;
    server_name fotougur.com.tr www.fotougur.com.tr dugunkarem.com.tr www.dugunkarem.com.tr;
    
    location / {
        proxy_pass http://localhost:3040;
        # ...
    }
}
```

### Dugunkarem Config (dugunkarem.com)

```nginx
server {
    listen 80;
    server_name dugunkarem.com www.dugunkarem.com;
    
    location / {
        proxy_pass http://localhost:3041;
        # ...
    }
}
```

## 📝 Yönetim Komutları

### PM2 Komutları

```bash
# Dugunkarem projesi
pm2 status dugunkarem-app
pm2 logs dugunkarem-app
pm2 restart dugunkarem-app
pm2 stop dugunkarem-app

# Foto-Ugur projesi
pm2 status foto-ugur-app
pm2 logs foto-ugur-app
pm2 restart foto-ugur-app
```

### Nginx Komutları

```bash
# Config test
sudo nginx -t

# Reload
sudo systemctl reload nginx

# Status
sudo systemctl status nginx
```

### Güncelleme

```bash
# Dugunkarem projesini güncelle
cd ~/dugunkarem
git pull origin main
npm ci
npm run build
pm2 restart dugunkarem-app --update-env

# Foto-Ugur projesini güncelle
cd ~/premiumfoto
git pull origin main
npm ci
npm run build
pm2 restart foto-ugur-app --update-env
```

## 🔍 Kontrol

```bash
# Port kontrolü
sudo lsof -i:3040  # Foto-Ugur
sudo lsof -i:3041  # Dugunkarem

# PM2 durumu
pm2 status

# Nginx config
sudo cat /etc/nginx/sites-available/dugunkarem
sudo cat /etc/nginx/sites-available/foto-ugur
```

## ✅ Doğrulama

- ✅ `fotougur.com.tr` → premiumfoto projesi (3040)
- ✅ `dugunkarem.com.tr` → premiumfoto projesi (3040)
- ✅ `dugunkarem.com` → dugunkarem projesi (3041)

