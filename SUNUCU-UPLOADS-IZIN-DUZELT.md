# 📁 Uploads Klasörü İzin Düzeltme

## 🔍 Sorun

Instagram'dan indirilen görseller `public/uploads` klasöründe var ama 404 hatası veriyor. Bu genellikle dosya izinleri veya Nginx yapılandırması ile ilgilidir.

## ✅ Çözüm

### 1. İzin Düzeltme Script'ini Çalıştır

```bash
cd ~/premiumfoto && \
bash scripts/fix-uploads-permissions.sh
```

### 2. Manuel İzin Düzeltme

```bash
cd ~/premiumfoto

# Uploads klasörünü oluştur (yoksa)
mkdir -p public/uploads

# Klasör izinleri: 755 (rwxr-xr-x)
chmod 755 public/uploads

# Tüm dosyalar için: 644 (rw-r--r--)
find public/uploads -type f -exec chmod 644 {} \;

# Tüm klasörler için: 755
find public/uploads -type d -exec chmod 755 {} \;

# Herkesin okuyabilmesi için
chmod -R a+r public/uploads

# Kontrol
ls -la public/uploads | head -10
```

### 3. Nginx Config Kontrolü

Nginx config dosyasında path'in doğru olduğundan emin olun:

```bash
# Nginx config dosyasını kontrol et
sudo cat /etc/nginx/sites-available/foto-ugur | grep -A 5 "location /uploads"

# Doğru path şöyle olmalı:
# alias /home/ibrahim/premiumfoto/public/uploads;
```

Eğer path yanlışsa düzeltin:

```bash
sudo nano /etc/nginx/sites-available/foto-ugur
```

Şu satırı bulun:
```nginx
location /uploads {
    alias /home/ibrahim/fotougur-app/public/uploads;  # ❌ YANLIŞ
```

Şöyle düzeltin:
```nginx
location /uploads {
    alias /home/ibrahim/premiumfoto/public/uploads;  # ✅ DOĞRU
    expires 30d;
    add_header Cache-Control "public, immutable";
    try_files $uri =404;
}
```

### 4. Nginx'i Yeniden Yükle

```bash
# Config test et
sudo nginx -t

# Hata yoksa reload
sudo systemctl reload nginx
```

### 5. Nginx Kullanıcısı İzinleri

Nginx'in dosyalara erişebilmesi için:

```bash
# Nginx kullanıcısını kontrol et
ps aux | grep nginx | head -1

# Genellikle www-data veya nginx kullanıcısı
# Eğer www-data ise:
sudo chown -R www-data:www-data public/uploads

# Veya nginx ise:
sudo chown -R nginx:nginx public/uploads

# Veya herkesin okuyabilmesi için:
chmod -R 755 public/uploads
find public/uploads -type f -exec chmod 644 {} \;
```

### 6. Veritabanı URL'lerini Düzelt

Dosyalar var ama URL'ler yanlışsa:

```bash
node scripts/fix-instagram-db-urls.js
```

## 🔥 Tek Komutla Tüm İşlemler

```bash
cd ~/premiumfoto && \
mkdir -p public/uploads && \
chmod 755 public/uploads && \
find public/uploads -type f -exec chmod 644 {} \; && \
find public/uploads -type d -exec chmod 755 {} \; && \
chmod -R a+r public/uploads && \
node scripts/fix-instagram-db-urls.js && \
sudo nginx -t && \
sudo systemctl reload nginx && \
echo "✅ İzinler düzeltildi!"
```

## 📋 Kontrol

```bash
# Dosya izinlerini kontrol et
ls -la public/uploads | head -10

# Nginx loglarını kontrol et
sudo tail -f /var/log/nginx/error.log

# Bir dosyayı test et
curl -I http://localhost/uploads/instagram-dugunkaremcom-*.jpg
```

## 🎯 Beklenen Sonuç

- Dosyalar `public/uploads` klasöründe
- İzinler: klasörler 755, dosyalar 644
- Nginx config path doğru
- Veritabanı URL'leri dosya adlarıyla eşleşiyor
- Görseller tarayıcıda görünüyor

