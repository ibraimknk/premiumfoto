# Foto Uğur - Sunucu Kurulum Rehberi

Bu rehber, Foto Uğur projesini Linux sunucuya kurmak için hazırlanmıştır.

## Gereksinimler

- Ubuntu 20.04+ veya Debian 11+
- Root veya sudo yetkisi
- En az 2GB RAM
- En az 10GB disk alanı

## Hızlı Kurulum

### 1. Proje Dosyalarını Sunucuya Yükleyin

```bash
# Git ile
git clone <repository-url> /var/www/foto-ugur

# veya SCP ile
scp -r . root@your-server:/var/www/foto-ugur
```

### 2. Kurulum Script'ini Çalıştırın

```bash
cd /var/www/foto-ugur
chmod +x deploy.sh
sudo bash deploy.sh
```

### 3. .env Dosyasını Düzenleyin

```bash
nano /var/www/foto-ugur/.env
```

Önemli değişkenler:
- `NEXTAUTH_URL`: Production domain adresiniz (örn: `https://fotougur.com`)
- `NEXTAUTH_SECRET`: Güvenli bir secret key (script otomatik oluşturur)
- `DATABASE_URL`: SQLite için `file:./prisma/dev.db` (PostgreSQL için farklı)

### 4. Nginx Domain Ayarları

```bash
nano /etc/nginx/sites-available/foto-ugur
```

`server_name _;` satırını domain adresinizle değiştirin:
```
server_name fotougur.com www.fotougur.com;
```

Nginx'i yeniden yükleyin:
```bash
nginx -t
systemctl reload nginx
```

### 5. SSL Sertifikası (Opsiyonel ama Önerilen)

```bash
certbot --nginx -d fotougur.com -d www.fotougur.com
```

## Güncelleme

Kod güncellemeleri için:

```bash
cd /var/www/foto-ugur
chmod +x deploy-update.sh
sudo bash deploy-update.sh
```

## Yönetim Komutları

### PM2 Komutları

```bash
# Durum kontrolü
pm2 status

# Logları görüntüle
pm2 logs foto-ugur-app

# Yeniden başlat
pm2 restart foto-ugur-app

# Durdur
pm2 stop foto-ugur-app

# Başlat
pm2 start foto-ugur-app
```

### Veritabanı Yönetimi

```bash
cd /var/www/foto-ugur

# Prisma Studio (GUI)
npm run db:studio

# Veritabanı seed (veri doldurma)
npm run db:seed

# Migration
npx prisma db push
```

### Nginx Komutları

```bash
# Konfigürasyon test
nginx -t

# Yeniden yükle
systemctl reload nginx

# Durum kontrolü
systemctl status nginx
```

## Port Yapılandırması

Uygulama varsayılan olarak **3040** portunda çalışır. Portu değiştirmek için:

1. `.env` dosyasında `PORT=3040` değerini değiştirin
2. Nginx config'de `proxy_pass http://localhost:3040;` satırını güncelleyin
3. PM2'yi yeniden başlatın: `pm2 restart foto-ugur-app`

## Sorun Giderme

### Uygulama Başlamıyor

```bash
# PM2 loglarını kontrol edin
pm2 logs foto-ugur-app --lines 50

# Port kullanımını kontrol edin
netstat -tulpn | grep 3040

# Node.js versiyonunu kontrol edin
node -v
```

### Veritabanı Hataları

```bash
# Veritabanı dosyasını kontrol edin
ls -lh /var/www/foto-ugur/prisma/dev.db

# Prisma client'ı yeniden oluşturun
cd /var/www/foto-ugur
npx prisma generate
```

### Nginx Hataları

```bash
# Nginx error loglarını kontrol edin
tail -f /var/log/nginx/error.log

# Konfigürasyonu test edin
nginx -t
```

## Güvenlik Notları

1. **.env dosyası**: Asla Git'e commit etmeyin
2. **Firewall**: Sadece gerekli portları açın (80, 443, 22)
3. **SSL**: Production'da mutlaka SSL kullanın
4. **Admin Şifresi**: İlk kurulumda admin şifresi `admin123` - **Mutlaka değiştirin!**

## Yedekleme

### Veritabanı Yedekleme

```bash
# SQLite veritabanını yedekle
cp /var/www/foto-ugur/prisma/dev.db /backup/dev-$(date +%Y%m%d).db

# Uploads klasörünü yedekle
tar -czf /backup/uploads-$(date +%Y%m%d).tar.gz /var/www/foto-ugur/public/uploads
```

### Otomatik Yedekleme (Cron)

```bash
crontab -e
```

Şu satırı ekleyin (her gün saat 02:00'de):
```
0 2 * * * /var/www/foto-ugur/scripts/backup.sh
```

## Performans Optimizasyonu

1. **PM2 Cluster Mode**: Çoklu instance için
   ```bash
   pm2 start npm --name foto-ugur-app -i max -- start
   ```

2. **Nginx Caching**: Statik dosyalar için cache ekleyin

3. **CDN**: Uploads klasörü için CDN kullanın

## Destek

Sorunlar için:
- PM2 logları: `pm2 logs foto-ugur-app`
- Nginx logları: `/var/log/nginx/`
- Uygulama logları: PM2 içinde

## Lisans

Bu proje özel bir projedir.

