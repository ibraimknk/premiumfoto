# HTTP 413 Hatası Çözümü

## ✅ Yapılan Değişiklikler

1. **Next.js Body Size Limit**: 10MB → 50MB
2. **Nginx Client Max Body Size**: 10M → 50M
3. **Dosya Boyutu Kontrolü**: API route'da 50MB limit kontrolü eklendi
4. **Hata Mesajları**: HTTP 413 için özel hata mesajı eklendi

## 🔧 Sunucuda Yapılacaklar

### 1. Güncellemeleri Çek

```bash
cd ~/premiumfoto && git pull origin main && npm run build && pm2 restart foto-ugur-app
```

### 2. Nginx Konfigürasyonunu Güncelle

```bash
# Nginx config dosyasını düzenle
sudo nano /etc/nginx/sites-available/foto-ugur
```

Şu satırı bulun:
```nginx
client_max_body_size 10M;
```

Şu şekilde değiştirin:
```nginx
client_max_body_size 50M;
```

Kaydedin ve Nginx'i yeniden yükleyin:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Alternatif: Tüm Nginx Konfigürasyonu

Eğer dosya yoksa veya yeniden oluşturmak isterseniz:

```bash
sudo nano /etc/nginx/sites-available/foto-ugur
```

İçeriğe şunu yazın:
```nginx
server {
    listen 80;
    server_name _;

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
        alias /var/www/foto-ugur/public/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

Kaydedin ve aktif edin:
```bash
sudo ln -sf /etc/nginx/sites-available/foto-ugur /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 📊 Yeni Limitler

- **Maksimum Dosya Boyutu**: 50MB
- **Toplam Yükleme**: 50MB (tek dosya)
- **Çoklu Dosya**: Her dosya maksimum 50MB

## ⚠️ Notlar

- 50MB'dan büyük dosyalar reddedilecek
- Hata mesajı kullanıcıya gösterilecek
- Nginx ve Next.js limitleri eşitlenmiş durumda

## 🔍 Test

1. Admin panelinde 50MB'dan küçük bir dosya yükleyin
2. 50MB'dan büyük bir dosya yüklemeyi deneyin - hata mesajı görmelisiniz

